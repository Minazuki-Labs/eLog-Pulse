class TicketsController < ApplicationController
  before_action :store_last_index_path, only: [ :index ]

  def index
    @scope = params[:scope] || "open"

    base_tickets = if current_user.school?
      current_user.reported_tickets
    elsif current_user.employee?
      Ticket.where(school_id: current_user.assigned_schools.select(:id))
    else
      current_user.admin? ? Ticket.all : Ticket.none
    end

    session[:last_tickets_path] = request.fullpath

    # Load schools available for filtering based on user role
    @schools = if current_user.admin?
      User.where(role: :school)
    elsif current_user.employee?
      current_user.assigned_schools
    else
      []
    end

    # Filter schools by state if present
    if params[:state].present?
      @schools = @schools.where(state: params[:state]) if @schools.respond_to?(:where)
    end

    # Load locations and equipment based on selected school_id
    @locations = params[:school_id].present? ? Location.where(school_id: params[:school_id]) : []
    @equipment = params[:location_id].present? ? Equipment.where(location_id: params[:location_id]) : []

    # Search query filter
    scoped_tickets = base_tickets
    if params[:query].present?
      q = "%#{params[:query].strip.downcase}%"

      # Determine if the query is a number to allow searching by Ticket ID
      id_condition = params[:query].strip.to_i > 0 ? "OR tickets.id = ?" : nil
      id_param = params[:query].strip.to_i > 0 ? params[:query].strip.to_i : nil

      scoped_tickets = scoped_tickets
        .left_joins(:school, :location, :issue_type, equipment: :equipment_category)
        .where(
          [
            "LOWER(tickets.teacher_name) LIKE ? OR " \
            "LOWER(tickets.teacher_email) LIKE ? OR " \
            "LOWER(tickets.teacher_phone_number) LIKE ? OR " \
            "LOWER(tickets.description) LIKE ? OR " \
            "LOWER(users.name) LIKE ? OR " \
            "LOWER(users.username) LIKE ? OR " \
            "LOWER(locations.name) LIKE ? OR " \
            "LOWER(issue_types.name) LIKE ? OR " \
            "LOWER(equipment_categories.name) LIKE ?",
            id_condition ? "#{id_condition.split('OR').last} OR ..." : nil
          ].compact.join(" OR "),
          q, q, q, q, q, q, q, q, q, *(id_param ? [ id_param ] : [])
        ).distinct
    end

    # State, School, Location, and Equipment filters
    if params[:state].present?
      scoped_tickets = scoped_tickets.joins(:school).where(users: { state: params[:state] })
    end

    if params[:school_id].present?
      scoped_tickets = scoped_tickets.where(school_id: params[:school_id])
    end

    if params[:location_id].present?
      scoped_tickets = scoped_tickets.where(location_id: params[:location_id])
    end

    if params[:equipment_id].present?
      scoped_tickets = scoped_tickets.where(equipment_id: params[:equipment_id])
    end

    # Date range filter
    if params[:start_date].present?
      scoped_tickets = scoped_tickets.where("tickets.created_at >= ?", params[:start_date].to_date.beginning_of_day)
    elsif @scope == "completed" && params[:end_date].blank?
      scoped_tickets = scoped_tickets.where("tickets.created_at >= ?", 30.days.ago.beginning_of_day)
    end

    if params[:end_date].present?
      scoped_tickets = scoped_tickets.where("tickets.created_at <= ?", params[:end_date].to_date.end_of_day)
    end

    if current_user.school?
      @tickets = scoped_tickets.includes(:location, { equipment: :equipment_category }, :issue_type).order(created_at: :desc)
    elsif @scope == "completed"
      @tickets = scoped_tickets.where(status: :completed).includes(:location, { equipment: :equipment_category }, :issue_type, :school).order(created_at: :desc)
    else
      current_scoped_tickets = case @scope
      when "open"
        scoped_tickets.open
      when "in_progress"
        scoped_tickets.where(status: :in_progress)
      else
        scoped_tickets
      end

      allowed_schools = if current_user.employee?
        current_user.assigned_schools
      else
        User.school
      end

      allowed_schools = allowed_schools.where(id: params[:school_id]) if params[:school_id].present?

      @states_data = User.states.keys.map do |state_key|
        state_schools = allowed_schools.where(state: state_key)

        active_schools = state_schools.map do |school|
          school_tickets = current_scoped_tickets.where(school_id: school.id).includes(:location, { equipment: :equipment_category }, :issue_type).order(created_at: :desc)
          { school: school, tickets: school_tickets } if school_tickets.any?
        end.compact

        { state: state_key, schools: active_schools } if active_schools.any?
      end.compact
    end

    respond_to do |format|
      format.html
      format.pdf do
        html_content = render_to_string(
          template: "tickets/completed_report_pdf",
          layout: false,
          formats: [ :html ]
        )

        send_data(
          Grover.new(html_content).to_pdf,
          filename: "completed_tickets_report_#{Date.today}.pdf",
          type: "application/pdf",
          disposition: "attachment"
        )
      end
    end
  end

  def show
    @ticket = Ticket.includes(:school, :equipment, :issue_type, :location, :comments).find(params[:id])
  end

  def new
    @ticket = Ticket.new
    setup_form_variables
  end

  def create
    @ticket = Ticket.new(ticket_params)

    @ticket.school = current_user if current_user.school?

    if @ticket.save
      redirect_to @ticket, notice: "Ticket was successfully created."
    else
      setup_form_variables
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @ticket = Ticket.find(params[:id])
    setup_form_variables
  end

  def update
    @ticket = Ticket.find(params[:id])

    if !current_user.admin? && ticket_params.key?(:status)
      redirect_to @ticket, alert: "You are not authorized to change the ticket status."
      return
    end

    if ticket_params[:status] == "new_case"
      redirect_to @ticket, alert: "Tickets cannot be changed back to New Case."
      return
    end

    @ticket.updater = current_user

    if @ticket.update(ticket_params)
      redirect_to @ticket, notice: "Status updated to #{@ticket.status.humanize}"
    else
      setup_form_variables
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @ticket = Ticket.find(params[:id])

    if current_user.admin? || current_user == @ticket.school
      @ticket.destroy
      redirect_to tickets_path, notice: "Ticket was successfully deleted.", status: :see_other
    else
      redirect_to @ticket, alert: "You are not authorized to delete this ticket."
    end
  end

  def locations
    @locations = Location.where(school_id: params[:school_id])
    render json: @locations.select(:id, :name)
  end

  def equipment
    @equipment = Equipment.where(location_id: params[:location_id])

    render json: @equipment.map { |e|
      { id: e.id, name: e.display_name || "Equipment #{e.id}" }
    }
  end

  def issue_types
    equipment = Equipment.find_by(id: params[:equipment_id])

    if equipment
      @issue_types = IssueType.where(equipment_category_id: equipment.equipment_category_id)
                              .order(Arel.sql("CASE WHEN name = 'Other' THEN 1 ELSE 0 END, name ASC"))
      render json: @issue_types.select(:id, :name)
    else
      render json: []
    end
  end

  def schools_by_state
    allowed_schools = if current_user.admin?
      User.where(role: :school)
    elsif current_user.employee?
      current_user.assigned_schools
    else
      User.none
    end

    schools = params[:state].present? ? allowed_schools.where(state: params[:state]) : allowed_schools
    render json: schools.select(:id, :name)
  end

  private

  def ticket_params
    params.require(:ticket).permit(:school_id, :location_id, :equipment_id, :issue_type_id, :description, :status, :resolved_at, :teacher_name, :teacher_phone_number, :teacher_email)
  end

  def setup_form_variables
    if current_user.school?
      @school = current_user
      @schools = [ @school ]
      @locations = @school.locations
    else
      @schools = User.where(role: :school)
      school_id = params.dig(:ticket, :school_id) || @ticket.school_id
      @locations = school_id.present? ? Location.where(school_id: school_id) : []
    end

    @equipment = @ticket.location_id ? Equipment.where(location_id: @ticket.location_id) : []

    @issue_types = if @ticket.equipment&.equipment_category_id
      IssueType.where(equipment_category_id: @ticket.equipment.equipment_category_id)
               .order(Arel.sql("CASE WHEN name = 'Other' THEN 1 ELSE 0 END, name ASC"))
    else
      []
    end
  end

  def store_last_index_path
    session[:last_tickets_path] = request.fullpath
  end
end

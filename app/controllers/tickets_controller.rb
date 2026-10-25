class TicketsController < ApplicationController
  before_action :store_last_index_path, only: [ :index ]

  def index
    @tickets = if current_user.school?
      current_user.reported_tickets
    elsif current_user.employee?
      Ticket.where(school_id: current_user.assigned_schools.select(:id))
    else
      current_user.admin? ? Ticket.all : Ticket.none
    end

    session[:last_tickets_path] = request.fullpath

    case params[:scope]
    when "open"
      @tickets = @tickets.open.not_completed
    when "assigned"
      if current_user.admin?
        @tickets = @tickets.joins(school: :employee_schools).distinct
      end
    end

    @tickets = @tickets.order(created_at: :desc)
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
      render json: @issue_types.select(:id, :name)
    else
      render json: []
    end
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
    @issue_types = @ticket.equipment&.equipment_category_id ? IssueType.where(equipment_category_id: @ticket.equipment.equipment_category_id) : []
  end

  def store_last_index_path
    session[:last_tickets_path] = request.fullpath
  end
end

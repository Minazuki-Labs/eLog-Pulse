class TicketsController < ApplicationController
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
    if @ticket.update(ticket_params)
      redirect_to @ticket, notice: "Status updated to #{@ticket.status.humanize}"
    else
      setup_form_variables
      render :edit, status: :unprocessable_entity
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
    params.require(:ticket).permit(:school_id, :location_id, :equipment_id, :issue_type_id, :description, :priority, :status)
  end

  def setup_form_variables
    if current_user.school?
      @school = current_user
      @schools = [ @school ]
      @locations = @school.locations
    else
      @schools = User.where(role: :school)
      @locations = @ticket.school ? @ticket.school.locations : []
    end

    @equipment = @ticket.location ? Equipment.where(location_id: @ticket.location_id) : []
    @issue_types = @ticket.equipment ? IssueType.where(equipment_category_id: @ticket.equipment.equipment_category_id) : []
  end
end

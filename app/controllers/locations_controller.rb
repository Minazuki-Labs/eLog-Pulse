class LocationsController < ApplicationController
  before_action :set_school, only: [ :index, :new, :create, :show ]

  def index
    if params[:query].present?
      @locations = @school.locations.where("LOWER(name) LIKE ?", "%#{params[:query].downcase}%")
    else
      @locations = @school.locations
    end
  end

  def show
    @location = @school.locations.find(params[:id])

    @equipment = @location.equipment.includes(:equipment_category)
    @tickets = @location.tickets.includes(:issue_type, :employee).order(created_at: :desc)

    assigned_category_ids = @equipment.pluck(:equipment_category_id)
    @equipment_categories = EquipmentCategory.where.not(id: assigned_category_ids)
  end

  def new
    @location = @school.locations.new

    @location.equipment.build

    @equipment_categories = EquipmentCategory.all
  end

  def create
    @location = @school.locations.new(location_params)

    if @location.save
      redirect_to user_path(@school), notice: "Location and equipment successfully added."
    else
      @equipment_categories = EquipmentCategory.all
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_school
    @school = User.school.find(params[:user_id])
  end

  def location_params
    params.require(:location).permit(:name, equipment_attributes: [ :id, :equipment_category_id, :_destroy ])
  end
end

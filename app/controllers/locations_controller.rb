class LocationsController < ApplicationController
  before_action :set_school, only: [ :new, :create ]

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
    @school = User.school.find(params[:school_id])
  end

  def location_params
    params.require(:location).permit(:name, equipment_attributes: [ :id, :equipment_category_id, :_destroy ])
  end
end

class EquipmentController < ApplicationController
  before_action :set_location

  def create
    @item = @location.equipment.new(equipment_params)
    if @item.save
      redirect_to user_location_path(@location.school, @location), notice: "Equipment added successfully."
    else
      redirect_to user_location_path(@location.school, @location), alert: "Failed to add equipment."
    end
  end

  def destroy
    @item = @location.equipment.find(params[:id])
    @item.destroy
    redirect_to user_location_path(@location.school, @location), notice: "Equipment removed successfully."
  end

  private

  def set_location
    @location = Location.find(params[:location_id])
  end

  def equipment_params
    params.require(:equipment).permit(:equipment_category_id)
  end
end

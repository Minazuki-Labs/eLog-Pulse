class LocationsController < ApplicationController
  before_action :set_school, only: [ :index, :new, :create, :show, :update_equipment ]

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
    @tickets = @location.tickets.includes(:issue_type).not_completed.order(created_at: :desc)

    @equipment_categories = EquipmentCategory.order(:name)
  end

  def new
    @location = @school.locations.new
    @equipment_categories = EquipmentCategory.all.order(:name)
  end

  def create
    @location = @school.locations.new(location_params)

    if @location.save
      # Handle saving selected equipment categories from checkboxes
      if params[:location][:equipment_category_ids].present?
        params[:location][:equipment_category_ids].reject(&:blank?).each do |cat_id|
          @location.equipment.create(equipment_category_id: cat_id)
        end
      end

      redirect_to user_path(@school), notice: "Location and equipment successfully added."
    else
      @equipment_categories = EquipmentCategory.all
      render :new, status: :unprocessable_entity
    end
  end

  def update_equipment
    @location = @school.locations.find(params[:id])
    selected_category_ids = params[:equipment_category_ids].to_a.map(&:to_i)

    current_category_ids = @location.equipment.pluck(:equipment_category_id)

    to_add = selected_category_ids - current_category_ids
    to_remove = current_category_ids - selected_category_ids

    to_add.each do |cat_id|
      @location.equipment.create(equipment_category_id: cat_id)
    end

    if to_remove.any?
      @location.equipment.where(equipment_category_id: to_remove).destroy_all
    end

    redirect_to user_location_path(@school, @location), notice: "Equipment list updated successfully."
  end

  private

  def set_school
    @school = User.school.find(params[:user_id])
  end

  def location_params
    params.require(:location).permit(:name)
  end
end

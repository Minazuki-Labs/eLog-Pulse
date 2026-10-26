class EquipmentCategoriesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_equipment_category, only: [ :show, :edit, :update, :destroy ]

  def index
    @equipment_categories = EquipmentCategory.includes(:issue_types).order(created_at: :desc)
    if params[:query].present?
      @equipment_categories = @equipment_categories.where("name ILIKE ?", "%#{params[:query]}%")
    end
  end

  def show
  end

  def new
    @equipment_category = EquipmentCategory.new
    @equipment_category.issue_types.build
  end

  def create
    @equipment_category = EquipmentCategory.new(equipment_category_params)
    if @equipment_category.save
      redirect_to equipment_categories_path, notice: "Equipment category created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @equipment_category.update(equipment_category_params)
      redirect_to equipment_category_path(@equipment_category), notice: "Equipment category updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @equipment_category = EquipmentCategory.find(params[:id])
    @equipment_category.destroy
    redirect_to equipment_categories_path, notice: "Equipment category and its related equipment were successfully removed."
  end

  private

  def set_equipment_category
    @equipment_category = EquipmentCategory.includes(:issue_types).find(params[:id])
  end

  def equipment_category_params
    params.require(:equipment_category).permit(:name, issue_types_attributes: [ :id, :name, :_destroy ])
  end
end

class CompaniesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_company, only: [ :show, :edit, :update, :destroy ]
  before_action :require_admin!

  def index
    @companies = Company.all
    if params[:query].present?
      @companies = @companies.where("name LIKE ?", "%#{params[:query]}%")
    end
  end

  def show
  end

  def new
    @company = Company.new
  end

  def create
    @company = Company.new(company_params)
    if @company.save
      redirect_to companies_path, notice: "Company was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @company.update(company_params)
      redirect_to companies_path, notice: "Company was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @company.destroy
    redirect_to companies_path, notice: "Company was successfully deleted."
  end

  private

  def set_company
    @company = Company.find(params[:id])
  end

  def require_admin!
    redirect_to root_path, alert: "Access denied." unless current_user.admin?
  end

  def company_params
    params.require(:company).permit(:name)
  end
end

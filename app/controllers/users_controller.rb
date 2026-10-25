class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_staff!, only: [ :new_school, :create_school, :edit, :update ]
  before_action :set_user, only: [ :show, :edit, :update ]

  def show
    if @user.school?
      @school = User.includes(:locations, :school_emails, reported_tickets: [ :equipment, :issue_type ]).find(params[:id])
    elsif @user.staff?
      @employee = User.includes(:assigned_schools).find(params[:id])
    end
  end

  def edit
    if @user.school?
      @school = @user
    elsif @user.staff?
      @employee = @user
    end
  end

  def update
    if @user.school?
      @school = @user
      if @school.update(school_params)
        redirect_to user_path(@school), notice: "School updated successfully."
      else
        render :edit, status: :unprocessable_entity
      end
    elsif @user.staff?
      @employee = @user
      if @employee.update(employee_params)
        redirect_to user_path(@employee), notice: "Employee updated successfully."
      else
        render :edit, status: :unprocessable_entity
      end
    end
  end

  def schools
    @schools = User.school.includes(:locations, :reported_tickets).order(:name)

    if params[:query].present?
      query = "%#{params[:query].strip}%"
      @schools = @schools.where("name ILIKE :q OR email ILIKE :q", q: query)
    end

    @schools = @schools.order(:name)

    render "users/schools"
  end

  def new_school
    @school = User.new(role: :school)
  end

  def create_school
    @school = User.new(school_params.merge(role: :school))

    if @school.save
      redirect_to schools_users_path, notice: "School successfully registered with an activation OTP!"
    else
      render :new_school, status: :unprocessable_entity
    end
  end

  def employees
    @employees = User.staff.includes(:assigned_schools).order(:name)

    if params[:query].present?
      query = "%#{params[:query].strip}%"
      @employees = @employees.where("name ILIKE :q OR username ILIKE :q", q: query)
    end

    render "users/employees"
  end

  def new_employee
    @employee = User.new(role: :employee)
  end

  def create_employee
    @employee = User.new(employee_params.merge(role: :employee))

    if @employee.save
      redirect_to employees_users_path, notice: "Employee successfully registered."
    else
      render :new_employee, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def ensure_staff!
    unless current_user&.staff?
      redirect_to root_path, alert: "You are not authorized to access this page."
    end
  end

  def school_params
    params.require(:user).permit(
      :name,
      :username,
      :password,
      :password_confirmation,
      :state,
      school_emails_attributes: [ :id, :email, :_destroy ]
    )
  end

  def employee_params
    params.require(:user).permit(
      :name,
      :username,
      :password,
      :password_confirmation
    )
  end
end

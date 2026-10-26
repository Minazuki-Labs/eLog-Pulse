class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_staff!, only: [ :schools, :employees ]
  before_action :ensure_admin!, only: [ :new_school, :create_school, :edit, :update, :toggle_role, :destroy, :edit_assignment, :update_assignment ]
  before_action :set_user, only: [ :show, :edit, :update, :edit_assignment, :update_assignment, :toggle_role, :destroy ]

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

  def edit_assignment
    @employee = @user
    @schools = User.school.order(:name)

    if params[:query].present?
      query = "%#{params[:query].strip}%"
      @schools = @schools.where("name ILIKE :q OR username ILIKE :q", q: query)
    end

    if params[:state].present?
      @schools = @schools.where(state: params[:state])
    end
  end

  def update_assignment
    @employee = @user
    school_ids = params[:school_ids] || []

    @employee.assigned_school_ids = school_ids

    redirect_to user_path(@employee), notice: "School assignments successfully updated."
  end

  def toggle_role
    if @user.school?
      redirect_to employees_users_path, alert: "Cannot change role of a school."
      return
    end

    new_role = @user.admin? ? :employee : :admin

    if @user.update(role: new_role)
      redirect_to user_path(@user), notice: "#{@user.name}'s role was updated to #{@user.role.titleize}."
    else
      redirect_to user_path(@user), alert: "Failed to update role."
    end
  end

  def destroy
    if @user == current_user
      redirect_to employees_users_path, alert: "You cannot delete your own account."
      return
    end

    user_type = @user.school? ? "School" : "Employee"
    redirect_path = @user.school? ? schools_users_path : employees_users_path

    if @user.destroy
      redirect_to redirect_path, notice: "#{user_type} was successfully deleted."
    else
      redirect_to user_path(@user), alert: "Failed to delete user."
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def ensure_admin!
    unless current_user&.admin?
      redirect_to root_path, alert: "You are not authorized to perform this action."
    end
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

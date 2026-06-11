class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_staff!, only: [ :new_school, :create_school ]

  def schools
    @schools = User.school.includes(:locations, :reported_tickets).order(:name)

    render "users/schools"
  end

  def new_school
    @school = User.new(role: :school)
  end

  def create_school
    @school = User.new(school_params.merge(role: :school))

    temporary_password = SecureRandom.hex(10)
    @school.password = temporary_password
    @school.password_confirmation = temporary_password

    if @school.save
      redirect_to schools_users_path, notice: "School successfully registered!"
    else
      render :new_school, status: :unprocessable_entity
    end
  end

  private

  def ensure_staff!
    unless current_user&.staff?
      redirect_to root_path, alert: "You are not authorized to access this page."
    end
  end

  def school_params
    params.require(:user).permit(:name, :email)
  end
end

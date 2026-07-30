class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_staff!, only: [ :new_school, :create_school, :edit, :update ]
  before_action :set_school, only: [ :show, :edit, :update ]

  def show
    @school = User.school.includes(:locations, reported_tickets: [ :equipment, :issue_type ]).find(params[:id])
  end

  def update
    if @school.update(school_params)
      redirect_to user_path(@school), notice: "School updated successfully."
    else
      render :edit, status: :unprocessable_entity
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

    temporary_password = SecureRandom.hex(16)
    @school.password = temporary_password
    @school.password_confirmation = temporary_password

    if @school.save
      raw_otp = sprintf("%06d", rand(10**6))

      @school.otp_codes.create!(
        token: raw_otp,
        expires_at: 24.hours.from_now
      )

      SchoolMailer.welcome_otp_email(@school, raw_otp).deliver_later

      redirect_to schools_users_path, notice: "School successfully registered with an activation OTP!"
    else
      render :new_school, status: :unprocessable_entity
    end
  end

  private

  def set_school
    @school = User.school.find(params[:id])
  end

  def ensure_staff!
    unless current_user&.staff?
      redirect_to root_path, alert: "You are not authorized to access this page."
    end
  end

  def school_params
    params.require(:user).permit(:name, :email)
  end
end

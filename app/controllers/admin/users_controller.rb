class Admin::UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_admin_or_employee

  def create
    @user = User.new(user_params)
    @user.password = SecureRandom.hex(16)

    if @user.save
      raw_token = @user.send_reset_password_instructions
      redirect_to admin_dashboard_path, notice: "User created and invitation email sent."
    else
      render :new
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :name, :role)
  end

  def ensure_admin_or_employee
    redirect_to root_path, alert: "Access denied." unless current_user.admin? || current_user.employee?
  end
end

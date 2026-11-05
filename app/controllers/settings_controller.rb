class SettingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user

  def edit
    if @user.school?
      @school = @user
    else
      @employee = @user
    end
  end

  def update
    if current_user.admin? && params[:app_config].present?
      AppConfig.group_email = params[:app_config][:group_email] if params[:app_config][:group_email].present?
    end

    if @user.school?
      @school = @user
      if @school.update(school_params)
        redirect_to edit_setting_path, notice: "Your settings were successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    else
      @employee = @user
      if @employee.update(employee_self_params)
        redirect_to edit_setting_path, notice: "Your settings were successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end
  end

  private

  def set_user
    @user = current_user
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

  def employee_self_params
    params.require(:user).permit(
      :name,
      :username,
      :email,
      :password,
      :password_confirmation
    )
  end
end

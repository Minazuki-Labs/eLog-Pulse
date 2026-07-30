class OtpSessionsController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :new, :create ]

  def new
  end

  def create
    user = User.find_by(email: params[:email])

    valid_otp = user&.otp_codes&.active&.find_by(token: params[:otp])

    if valid_otp
      user.otp_codes.destroy_all

      sign_in(user)
      redirect_to root_path, notice: "Welcome aboard!"
    else
      flash.now[:alert] = "The OTP code entered is invalid or has expired."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    sign_out(current_user) if user_signed_in?
    redirect_to root_path, notice: "Logged out successfully."
  end
end

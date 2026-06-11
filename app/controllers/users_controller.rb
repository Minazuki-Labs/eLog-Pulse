class UsersController < ApplicationController
  before_action :authenticate_user!

  def schools
    @schools = User.school.includes(:locations, :reported_tickets).order(:name)

    render "users/schools"
  end
end

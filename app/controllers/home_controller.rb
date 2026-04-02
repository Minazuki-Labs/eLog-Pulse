class HomeController < ApplicationController
  before_action :authenticate_user!

  def index
    @tickets = Ticket.order(created_at: :desc)
  end
end

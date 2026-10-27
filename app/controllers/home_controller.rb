class HomeController < ApplicationController
  before_action :authenticate_user!

  def index
    if current_user.school?
      @tickets = current_user.reported_tickets.not_completed.includes(:location, { equipment: :equipment_category }, :issue_type).order(created_at: :desc)
    else
      @states_data = User.states.keys.map do |state_key|
        state_schools = User.school.where(state: state_key).includes(reported_tickets: [ :location, { equipment: :equipment_category }, :issue_type ])

        active_schools = state_schools.map do |school|
          not_completed_tickets = school.reported_tickets.select { |t| !t.completed? }
          { school: school, tickets: not_completed_tickets } if not_completed_tickets.any?
        end.compact

        { state: state_key, schools: active_schools } if active_schools.any?
      end.compact
    end
  end
end

class HomeController < ApplicationController
  before_action :authenticate_user!

  def index
    if current_user.school?
      @tickets = current_user.reported_tickets.not_completed.includes(:location, { equipment: :equipment_category }, :issue_type).order(created_at: :desc)
    else
      use_assigned_schools = current_user.admin? ? current_user.assigned_schools.any? : current_user.employee?

      base_tickets = if current_user.contractor?
        current_user.assigned_tickets.where(status: :in_progress)
      elsif use_assigned_schools
        Ticket.where(school_id: current_user.assigned_schools.select(:id)).not_completed
      else
        Ticket.all.not_completed
      end

      allowed_schools = if use_assigned_schools
        current_user.assigned_schools
      elsif current_user.contractor?
        User.joins(:reported_tickets).where(tickets: { id: base_tickets.select(:id) }).distinct
      else
        User.school
      end

      @states_data = User.states.keys.map do |state_key|
        state_schools = allowed_schools.where(state: state_key)

        active_schools = state_schools.map do |school|
          school_tickets = base_tickets.where(school_id: school.id).includes(:location, { equipment: :equipment_category }, :issue_type).order(created_at: :desc)

          active_count = school_tickets.select { |t| t.new_case? || t.in_progress? }.count
          { school: school, tickets: school_tickets } if active_count > 0
        end.compact

        { state: state_key, schools: active_schools } if active_schools.any?
      end.compact
    end
  end
end

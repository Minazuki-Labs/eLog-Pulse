module TicketsHelper
  def ticket_page_title
    case params[:scope]
    when "open"        then "New Tickets"
    when "in_progress" then "In Progress"
    when "completed"   then "Completed Tickets"
    else
      current_user.school? ? "My Tickets" : "All Tickets"
    end
  end

  def ticket_page_description
    case params[:scope]
    when "open"        then "New tickets awaiting action."
    when "in_progress" then "Tickets currently being worked on."
    when "completed"   then "Resolved and completed tickets."
    else
      current_user.school? ? "Track and manage your submitted requests." : "Overview of all activity."
    end
  end
end

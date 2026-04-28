module TicketsHelper
  def ticket_page_title
    case params[:scope]
    when "assigned" then "Assigned to Me"
    when "open"     then "Open Tickets"
    when "pending"  then "Pending Tickets"
    else
      current_user.school? ? "My Tickets" : "All Tickets"
    end
  end

  def ticket_page_description
    case params[:scope]
    when "assigned" then "Tickets currently assigned to your account."
    when "open"     then "All tickets awaiting action."
    else
      current_user.school? ? "Track and manage your submitted requests." : "Overview of all activity."
    end
  end
end

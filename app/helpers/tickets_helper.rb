module TicketsHelper
  def ticket_page_title
    case params[:scope]
    when "assigned" then "My Tickets"
    when "open"     then "Open Tickets"
    else
      current_user.school? ? "My Tickets" : "All Tickets"
    end
  end

  def ticket_page_description
    case params[:scope]
    when "assigned" then "Tickets from school assigned to you."
    when "open"     then "New tickets awaiting action."
    else
      current_user.school? ? "Track and manage your submitted requests." : "Overview of all activity."
    end
  end
end

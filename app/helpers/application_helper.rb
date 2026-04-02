module ApplicationHelper
  def status_color(status)
    case status
    when "pending"
      "bg-amber-100 text-amber-700 border border-amber-200"
    when "in_progress"
      "bg-blue-100 text-blue-700 border border-blue-200"
    when "completed"
      "bg-emerald-100 text-emerald-700 border border-emerald-200"
    else
      "bg-gray-100 text-gray-600 border border-gray-200"
    end
  end
end

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

  def sidebar_link(label, path, icon)
    active = current_page?(path)

    link_class = active ?
      "flex items-center px-4 py-3 text-sm font-bold text-blue-600 bg-blue-50 rounded-xl mb-2 transition-all" :
      "flex items-center px-4 py-3 text-sm font-semibold text-gray-400 hover:bg-gray-50 rounded-xl transition-all mb-2"

    link_to path, class: link_class do
      content_tag(:span, label)
    end
  end
end

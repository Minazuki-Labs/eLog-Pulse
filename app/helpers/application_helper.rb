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

  def sidebar_link(label, path, icon_name)
    active = current_page?(path)

    base_class = "group flex items-center gap-4 px-5 py-3.5 text-sm font-medium rounded-xl transition-all duration-200 ease-in-out"

    link_class = active ?
      "#{base_class} text-blue-600 bg-blue-50/80 shadow-sm ring-1 ring-blue-700/10" :
      "#{base_class} text-gray-500 hover:text-gray-900 hover:bg-gray-100/80"

    link_to path, class: link_class do
      icon_class = active ? "w-5 h-5 text-blue-600" : "w-5 h-5 text-gray-400 group-hover:text-gray-600"

      concat heroicon(icon_name, variant: :outline, options: { class: icon_class })
      concat content_tag(:span, label)
    end
  end
end

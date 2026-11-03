module StockOrdersHelper
  def stock_status_color(status)
    case status
    when "pending"
      "bg-yellow-100 text-yellow-800"
    when "in_delivery"
      "bg-purple-100 text-purple-800"
    when "completed"
      "bg-emerald-100 text-emerald-800"
    when "rejected"
      "bg-rose-100 text-rose-800"
    else
      "bg-slate-100 text-slate-850"
    end
  end
end

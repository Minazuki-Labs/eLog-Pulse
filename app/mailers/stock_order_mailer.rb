class StockOrderMailer < ApplicationMailer
  def order_created(stock_order)
    @stock_order = stock_order
    @requester = stock_order.user
    @email = stock_order.teacher_email

    return if @email.blank?

    mail(
      to: @email,
      subject: "Stock Order Created ##{@stock_order.id}"
    )
  end

  def approval_required(stock_order, recipient)
    @stock_order = stock_order
    @recipient = recipient

    return if @recipient&.email.blank?

    mail(
      to: @recipient.email,
      subject: "Action Required: New Stock Order ##{@stock_order.id}"
    )
  end

  def order_in_delivery(stock_order)
    @stock_order = stock_order
    @requester = stock_order.user
    @email = stock_order.teacher_email

    return if @email.blank?

    mail(
      to: @email,
      subject: "Stock Order ##{@stock_order.id} is In Delivery"
    )
  end

  def order_completed(stock_order)
    @stock_order = stock_order
    @contractor = stock_order.contractor

    return if @contractor&.email.blank?

    mail(
      to: @contractor.email,
      subject: "Stock Order ##{@stock_order.id} Completed"
    )
  end
end

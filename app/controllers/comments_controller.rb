class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_ticket
  before_action :require_staff!

  def create
    @ticket.updater = current_user

    if params[:complete_case] == "1"
      @ticket.status = :completed
    elsif @ticket.new_case?
      @ticket.status = :in_progress
    end

    @comment = @ticket.comments.build(comment_params)
    @comment.user = current_user

    success = ActiveRecord::Base.transaction do
      ticket_saved = @ticket.changed? ? @ticket.save : true
      comment_saved = @comment.save

      ticket_saved && comment_saved
    end

    if success
      status_msg = @ticket.saved_change_to_status? ? " and status updated to #{@ticket.status.humanize}" : ""
      redirect_to @ticket, notice: "Comment posted successfully#{status_msg}."
    else
      @ticket = Ticket.includes(:school, :equipment, :issue_type, :location, :comments).find(params[:ticket_id])
      flash.now[:alert] = "Comment could not be posted: #{@comment.errors.full_messages.to_sentence}"
      render "tickets/show", status: :unprocessable_entity
    end
  end

  private

  def set_ticket
    @ticket = Ticket.find(params[:ticket_id])
  end

  def require_staff!
    unless current_user.staff?
      redirect_to @ticket, alert: "You are not authorized to post comments."
    end
  end

  def comment_params
    params.require(:comment).permit(:body, :jobsheet)
  end
end

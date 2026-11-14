class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_ticket
  before_action :authorize_commenter!

  def create
    @ticket.updater = current_user

    if params[:complete_case] == "1" && current_user.staff?
      @ticket.status = :completed
    elsif @ticket.new_case? && current_user.staff?
      @ticket.status = :in_progress
    elsif @ticket.completed? && current_user.school?
      @ticket.status = :new_case
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

  def authorize_commenter!
    allowed = if current_user.staff?
      !@ticket.completed?
    elsif current_user.school?
      current_user == @ticket.school && @ticket.editable_by_school?
    else
      false
    end

    unless allowed
      redirect_to @ticket, alert: "You are not authorized to post comments on this ticket."
    end
  end

  def comment_params
    params.require(:comment).permit(:body, :jobsheet, :attachment)
  end
end

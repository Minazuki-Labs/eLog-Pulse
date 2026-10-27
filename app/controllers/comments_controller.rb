class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_ticket
  before_action :require_staff!

  def create
    @comment = @ticket.comments.build(comment_params)
    @comment.user = current_user

    if @ticket.new_case?
      @ticket.updater = current_user
      @ticket.status = :in_progress
    end

    if @comment.save && (@ticket.changed? ? @ticket.save : true)
      redirect_to @ticket, notice: "Comment posted successfully and status updated to In Progress."
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

class TicketMailer < ApplicationMailer
  def new_ticket(ticket)
    @ticket = ticket
    @school = @ticket.school

    # Gather recipients: App config group email + all school emails for this school
    recipients = []

    group_email = AppConfig.group_email
    recipients << group_email if group_email.present?

    if @school.present?
      school_emails = @school.school_emails.pluck(:email)
      recipients.concat(school_emails)
    end

    recipients << @ticket.teacher_email if @ticket.teacher_email.present?

    recipients = recipients.compact.uniq

    return if recipients.empty?

    mail(
      to: recipients,
      subject: "New Ticket Created ##{@ticket.id}"
    )
  end

  def new_comment(comment)
    @comment = comment
    @ticket = comment.ticket.reload
    @school = @ticket.school

    # Fetch comments excluding system logs
    @comments = @ticket.comments.where.not(comment_type: :system_log).order(created_at: :desc)

    # Gather recipients: App config group email + all school emails for this school
    recipients = []

    group_email = AppConfig.group_email
    recipients << group_email if group_email.present?

    if @school.present?
      school_emails = @school.school_emails.pluck(:email)
      recipients.concat(school_emails)
    end

    recipients << @ticket.teacher_email if @ticket.teacher_email.present?

    recipients = recipients.compact.uniq

    return if recipients.empty?

    mail(
      to: recipients,
      subject: "Update on Ticket ##{@ticket.id} - Status: #{@ticket.status.humanize}"
    )
  end
end

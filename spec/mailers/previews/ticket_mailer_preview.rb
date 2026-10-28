# Preview all emails at http://localhost:3000/rails/mailers/ticket_mailer_mailer
class TicketMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/ticket_mailer_mailer/new_comment
  def new_comment
    TicketMailer.new_comment
  end

end

class DeviseMailer < Devise::Mailer
  include Devise::Controllers::UrlHelpers
  default template_path: 'devise/mailer'
  default from: "Roomify <bhuwadol.sriton@odds.team>"
  
  # Override the default reset_password_instructions method
  def reset_password_instructions(record, token, opts={})
    # Use our custom mailer for password reset
    UserMailer.password_reset_email(record, token).deliver_later
  end
end 
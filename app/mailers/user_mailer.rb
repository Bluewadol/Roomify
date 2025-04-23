class UserMailer < ApplicationMailer
  # Send welcome email to newly registered users
  def welcome_email(user)
    @user = user
    @login_url = new_user_session_url
    
    mail(
      to: @user.email,
      subject: "Welcome to #{app_name}!"
    )
  end
  
  # Send password reset email
  def password_reset_email(user, reset_token)
    @user = user
    @reset_url = edit_user_password_url(reset_token: reset_token)
    
    mail(
      to: @user.email,
      subject: "Reset your #{app_name} password"
    )
  end
end 
# Preview all emails at http://ENV['host_ip']/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview

  # Preview this email at http://ENV['host_ip']/rails/mailers/user_mailer/welcome
  def welcome
    UserMailer.welcome
  end

end

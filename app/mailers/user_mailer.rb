class UserMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.welcome.subject
  #
  def inviteProject(email, owner, message, project)
    @email = email
    @owner = owner
    @project = project
    @message = message
    mail to:@email, subject: "[daldalTask] 프로젝트 초대"
  end

  def verify(user)
    @user = user
    mail to:@user.account, subject: "[daldalTask] 인증하기!"
  end

  def welcome(email)
    mail to:email, subject: "[daldalTask] 환영합니다!!"
  end

  def inviteDaldalTask(email, owner, message)
    @owner = owner
    @message = message
    mail to:email, subject: "[daldalTask] 당신을 초대합니다!!"
  end

  def resetPassword(user)
    @user = user
    mail to:@user.account, subject: "[daldalTask] 비밀번호 다시 설정하기"
  end

end

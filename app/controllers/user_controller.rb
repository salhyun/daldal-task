class UserController < ApplicationController
  skip_before_action :verify_authenticity_token

  def self.existSNSAccount(user)
    if GoogleAccount.exists?(user: user)
      return 'google'
    end
    if KakaoAccount.exists?(user: user)
      return 'kakao'
    end
    if NaverAccount.exists?(user: user)
      return 'naver'
    end
    return nil
  end

  def testAccount
    users = User.all

    names = Array.new
    users.each do |user|
      names.push(user.name)
    end

    render json: {result: true, names: names}
  end

  def postNames
    users = User.all

    names = Array.new
    users.each do |user|
      names.push(user.name)
    end

    render json: {result: true, names: names}
  end

  def sendTestMail
    mailer_response = UserMailer.welcome(params[:email]).deliver
    render json: {result: true, response: mailer_response, message: 'sent email successfully!'}
  end

  def appLogin
    logger.info('params account: ')
    logger.info(params[:account])
    if User.find_by(account: params[:account])
      render json: {result: true, message: "appLogin"}
    else
      render json: {result: true, message: "doesn't exist"}
    end
  end

  def checkEmail
    user = User.find_by(account: params[:email])
    if user
      kinds = Array.new
      kinds.push('email')
      snsName = UserController.existSNSAccount(user)
      if snsName
        kinds.push(snsName)
      end
      user.update(secure_code: SecureRandom.hex(16))
      UserMailer.resetPassword(user).deliver
      render json: {result: true, kinds: kinds}
    else
      render json: {result: false}
    end
  end

  def checkAccount
    if User.exists?(account: params[:account])
      if params[:kind]
        if checkSNSAccount(params[:kind], params[:token])
          render json: {result: true, exist: ['email', 'sns']}
        else
          render json: {result: true, exist: ['email']}
        end
      else
        render json: {result: true, exist: ['email']}
      end
    else
      render json: {result: false}
    end
  end

  def checkSNSAccount(kind, token)
    if kind == 'google'
      logger.info('checkSNSAccount google')
      account = GoogleAccount.find_by(sub: token)
    elsif kind == 'kakao'
      logger.info('checkSNSAccount kakao')
      account = KakaoAccount.find_by(account_id: token)
    elsif kind == 'naver'
      logger.info('checkSNSAccount naver')
      account = NaverAccount.find_by(account_id: token)
    end
    logger.info(account)
    if account
      return account.user
    end
    return nil
  end
  def createSNSAccount(kind, token, user)
    if kind == 'google'
      account = GoogleAccount.new(sub: token, user: user)
    elsif kind == 'kakao'
      account = KakaoAccount.new(account_id: token, user: user)
    elsif kind == 'naver'
      account = NaverAccount.new(account_id: token, user: user)
    end
    if account
      account.save
      return true
    end
    return false
  end

  def create
    if User.exists?(account: params[:account])
      render json: {result: false, message: "Account already exists."}
    else
      account = params[:account]
      password = Digest::SHA256.hexdigest(params[:password])
      nickname = (params[:nickname] == "") ? account.split('@')[0] : params[:nickname]
      user = User.new(account: account, password: password, name: nickname, verified: false, secure_code: SecureRandom.hex(16), notification_order: nil)
      if user.save
        arrangedInvitation = ArrangedInvitation.find_by(account: user.account)
        if arrangedInvitation
          Invitation.new(requestor: arrangedInvitation.project.creator, accepter: user, agreed: true).save
          projectMember = ProjectMember.new(project: arrangedInvitation.project, user: user, roletype: Roletype.find_by(name: 'worker'))
          projectMember.save
          arrangedInvitation.destroy
        end
        UserMailer.verify(user).deliver
        render json: {result: true, message: "success!"}
      else
        render json: {result: false, message: "It can't connect database"}
      end
    end
  end

  def createWithSNS
    user = checkSNSAccount(params[:kind], params[:token])
    unless user
      user = User.find_by(account: params[:email])
      unless user
        password = Digest::SHA256.hexdigest(params[:token])
        user = User.new(account: params[:email], password: password, name: params[:nickname], avatar: params[:avatar], verified: false, secure_code: SecureRandom.hex(16), notification_order: nil)
        if user.save
          if createSNSAccount(params[:kind], params[:token], user)
            arrangedInvitation = ArrangedInvitation.find_by(account: user.account)
            if arrangedInvitation
              projectMember = ProjectMember.new(project: arrangedInvitation.project, user: user, roletype: Roletype.find_by(name: 'worker'))
              projectMember.save
              arrangedInvitation.destroy
            end
            UserMailer.verify(user).deliver
            render json: {result: true, how: 'new'}
          else
            render json: {result: false, message: "It can't connect database"}
          end
        else
          render json: {result: false, message: "It can't connect database"}
        end
      else #이메일로 직접 가입한 계정이 있다면 그 계정과 연동시킴
        if createSNSAccount(params[:kind], params[:token], user)
          session[:logined] = true
          session[:user] = user
          render json: {result: true, how: 'merge'}
        else
          render json: {result: false, message: "It can't connect database"}
        end
      end
    else #이미 SNSAccount에 계정이 있다면 그냥 로그인 시킴
      session[:logined] = true
      session[:user] = user
      render json: {result: true, how: 'existed'}
    end
  end

  def acceptInvitation
    @accept = false
    @message = ''
    logger.info('email = ' + params[:email])
    logger.info('ownerId = ' + params[:ownerId])
    user = User.find_by(account: params[:email])
    owner = User.find(params[:ownerId])
    if user and owner
      project = Project.find(params[:projectId])
      if project
        if project.users.exists?(id: user.id)
          @message = t('user.this_account_already_exists')
        else
          projectMember = ProjectMember.new(project: project, user: user, roletype: Roletype.find_by(name: 'worker'))
          projectMember.save
          @message = t('application.processing_was_successful')
        end

        invitation = Invitation.find_by(requestor: owner, accepter: user)
        if invitation
          invitation.update(agreed: true)
        end

        # project.users.each do |user|
        #   roletype = ProjectMember.find_by(project: project, user: user).roletype
        #   logger.info(roletype.name_kr)
        # end

        @accept = true
      else
        @message = t('application.cant_find_what', what: t('dashboard.project'))
      end
    else
      @message = t('application.cant_find_what', what: t('user.user'))
    end
  end

  def resetPassword
    if request.get?
      @validAccess = false
      user = User.find_by(id: params[:userId])
      if user
        if user.secure_code and user.secure_code == params[:secure_code]
          @validAccess = true
        end
      else
        @message = t('application.cant_find_what', what: t('user.user'))
      end
    elsif request.post?
      user = User.find(params[:userId])
      if user
        user.update(password: Digest::SHA256.hexdigest(params[:newPassword]), secure_code: nil)
        render json: {result: true, message: "password updated successfully!"}
      else
        render json: {result: false, message: "can't find account"}
      end
    end
  end

  def verify
    @verify = false
    @message = ''
    user = User.find_by(id: params[:userId])
    if user
      if user.secure_code == params[:secure_code]
        if user.verified == false
          user.verified = true
          user.secure_code = nil
          user.save
          @verify = user.verified
          @message = t('user.verification_was_successful')
        else
          @message = t('user.already_verified')
        end
      else
        @message = t('user.invalid_verification_token')
      end
    else
      @message = t('application.cant_find_what', what: t('user.user'))
    end
  end

  def login
    if request.post?
      if User.exists?(account: params[:account])
        user = User.find_by(account: params[:account], password: Digest::SHA256.hexdigest(params[:password]))
        if user
          if user.verified == true
            session[:logined] = true
            session[:user] = user
            render json: {result: true, account: user.account, name: user.name, avatar: user.avatar}
          else
            render json: {result: false, message: t('user.account_not_verified')}
          end
        else
          render json: {result: false, message: "wrong passwrod"}
        end
      else
        render json: {result: false, message: "can't find account"}
      end
    end
  end
  def loginWithSNS
    user = checkSNSAccount(params[:kind], params[:token])
    if user
      if user.verified == true
        session[:logined] = true
        session[:user] = user
        render json: {result: true, account: user.account, name: user.name, avatar: user.avatar}
      else
        render json: {result: false, message: t('user.account_not_verified')}
      end
    else
      render json: {result: false, message: t('user.account_does_not_exist')}
    end
  end

  def logout
    reset_session
    redirect_to controller: :main, action: :index
  end

  def readMyProjects
    user = User.find(params[:userId])
    if user
      myProjects = Project.where(creator: user)
      render json: {result: true, projects: myProjects, message: "success"}
    else
      render json: {result: false, message: "can't find account"}
    end
  end

  def readBelongToProjects
    user = User.find(params[:userId])
    if user
      belongToProjects = user.belong_projects.where.not(creator: user)
      render json: {result: true, projects: belongToProjects, message: "success"}
    else
      render json: {result: false, message: "can't find account"}
    end
  end

  def createProject
    user = User.find(params[:userId])
    if user
      project = Project.new(title: params[:title], desc: params[:desc], creator: user)
      project.save

      roletype = Roletype.find_by(name: 'administrator')
      if roletype
        projectMember = ProjectMember.new(project: project, user: user, roletype: roletype)
        projectMember.save
      end

      if params[:emails]
        params[:emails].each do |email|
          if User.exists?(account: email)
            UserMailer.inviteProject(email, user, params[:message] ? params[:message] : "", project).deliver
          else
            UserMailer.inviteDaldalTask(email, user, params[:message] ? params[:message] : "").deliver
            ArrangedInvitation.new(account: email, project: project).save
          end
        end
      end

      section = Section.new(title: '대기', project: project, order: nil, color: '#F6402C')
      section.save
      section = Section.new(title: '진행중', project: project, order: nil, color: '#1093F5')
      section.save
      section = Section.new(title: '완료', project: project, order: nil, color: '#5E7C8B')
      section.save

      render json: {result: true, project: project, message: "success"}
    else
      render json: {result: false, message: "can't find account"}
    end
  end

  def changePassword
    user = User.find(params[:userId])
    if user
      user.update(password: Digest::SHA256.hexdigest(params[:newPassword]))
      session[:user]['password'] = user.password
      render json: {result: true, message: "password updated successfully!"}
    else
      render json: {result: false, message: "can't find account"}
    end
  end

  def changeName
    user = User.find(params[:userId])
    if user
      user.update(name: params[:newName])
      if user.save
        session[:user]['name'] = user.name
        render json: {result: true, name: user.name}
      else
        render json: {result: false, message: "can't save nickName"}
      end
    else
      render json: {result: false, message: "can't find account"}
    end
  end

  def updateAvatarUrl
    user = User.find(params[:userId])
    if user
      user.update(avatar: params[:avatarUrl])
      if user.save
        session[:user]['avatar'] = user.avatar
        render json: {result: true, avatar: user.avatar}
      else
        render json: {result: false, message: "can't save avatar"}
      end
    else
      render json: {result: false, message: "can't find account"}
    end
  end

  def deleteNotification
    user = User.find(params[:userId])
    if user
      result = NotificationController.deleteNotification(user, params[:notificationId])
      if result['result']
        render json: {result: true}
      else
        render json: {result: false, message: result['message']}
      end
    else
      render json: {result: false, message: "can't find account"}
    end
  end

  def new
    @naver_access_token = params[:access_token]
  end

  def decodeJWT
    decoded_token = JWT.decode params[:token], nil, false
    render json: {result: true, decoded_token: decoded_token}
  end

  def confirmSNSEmail
    #먼저 각 SNS테이블에 token 추가하고, user 테이블에 추가
  end

  def oauthRedirect
    logger.info('OAuth Redirect')
    @clientId = ENV['google_client_id']
    logger.info(@clientId)
  end

  def withdrawAccount
    user = User.find(params[:userId])
    if user
      ApplicationController.cleanupUserBeforeDestroy(params[:userId])
      session[:user] = nil
      session[:logined] = false
      user.destroy
      render json: {result: true, message: 'user has deleted successfully'}
    else
      render json: {result: false, message: "can't find user"}
    end
  end

  def getAllAttachmentsFromUser
    user = User.find(params[:userId])
    if user
      attachments = Array.new
      user.tasks.each do |task|
        task.attachments.each do |attachment|
          content = {name: attachment.name, taskId: task.id}
          attachments.push(content)
        end
      end
      render json: {result: true, attachments: attachments}
    else
      render json: {result: false, message: "can't find user"}
    end
  end

  def withdrawUser
    user = User.find(params[:userId])
    if user
      ApplicationController.cleanupUserBeforeDestroy(params[:userId])

      googleAccount = GoogleAccount.find_by(user: user)
      if googleAccount
        googleAccount.destroy
      end
      kakaoAccount = KakaoAccount.find_by(user: user)
      if kakaoAccount
        kakaoAccount.destroy
      end
      naverAccount = NaverAccount.find_by(user: user)
      if naverAccount
        naverAccount.destroy
      end

      session[:user] = nil
      session[:logined] = false
      user.destroy
      render json: {result: true, message: 'user has deleted successfully'}
    else
      render json: {result: false, message: "can't find user"}
    end
  end

end

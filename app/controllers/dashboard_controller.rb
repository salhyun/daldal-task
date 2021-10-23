class DashboardController < ApplicationController
  def readInvitations
    user = User.find_by(id: params[:userId])
    if user
      invitations = user.invitations
      if invitations
        friends = Array.new
        invitations.each do |inv|
          friends.push(inv.accepter)
        end
        render json: {result: true, friends: friends}
      else
        render json: {result: false, message: "there is no friends"}
      end
    else
      render json: {result: false, message: "can't find user"}
    end
  end

  def readProjectMembers
    project = Project.find(params[:projectId])
    if project
      members = Array.new
      logger.info(project.users.count)
      project.project_members.each do |pmember|
        members.push({'id' => pmember.user.id, 'account' => pmember.user.account, 'name' => pmember.user.name, 'role' => pmember.roletype.name_kr, 'pmid' => pmember.id})
      end
      render json: {result: true, members: members}
    else
      render json: {result: false, message: "can't find project"}
    end
  end

  def deleteProjectMember
    projectMember = ProjectMember.find(params[:pmId])
    if projectMember
      projectMember.destroy
      render json: {result: true, message: 'success'}
    else
      render json: {result: false, message: "can't find projectMember"}
    end
  end

  def changeRole
    projectMember = ProjectMember.find(params[:pmId])
    if projectMember
      role = Roletype.find(params[:roletypeId])
      if role
        projectMember.update(roletype: role)
        render json: {result: true, roletype: projectMember.roletype.name_kr}
      else
        render json: {result: false, message: "can't find roletype"}
      end
    else
      render json: {result: false, message: "can't find ProjectMember"}
    end
  end

  def deleteProject
    project = Project.find(params[:projectId])
    if project
      ApplicationController.cleanupProjectBeforeDestroy(project)
      project.destroy
      render json: {result: true, message: 'success'}
    else
      render json: {result: false, message: "can't find project"}
    end
  end

  def inviteAccounts
    owner = User.find(params[:ownerId])
    project = Project.find(params[:projectId])
    if owner and project
      params[:accounts].each do |account|
        user = User.find_by(account: account)
        if user
          UserMailer.inviteProject(account, owner, params[:message], project).deliver
          unless Invitation.exists?(requestor: owner, accepter: user)
            Invitation.new(requestor: owner, accepter: user).save
          end
        else
          #아직 가입하지 않은 유저는 arrangedInvitation 테이블에 먼저 넣고 가입메일 보낸다
          arrangedInvitation = ArrangedInvitation.new(account: account, project: project)
          arrangedInvitation.save
          # 메일 보내기
          UserMailer.inviteDaldalTask(account, owner, params[:message]).deliver
        end
      end
      render json: {result: true, message: "inviteAccounts"}
    end
  end

  def renameProjectTitle
    project = Project.find(params[:projectId])
    if project
      project.update(title: params[:title])
      project.save
      render json: {result: true, title: project.title}
    else
      render json: {result: false, message: "can't find project"}
    end
  end
  def renameProjectDesc
    project = Project.find(params[:projectId])
    if project
      project.update(desc: params[:desc])
      project.save
      render json: {result: true, desc: project.desc}
    else
      render json: {result: false, message: "can't find project"}
    end
  end

  def readProject
    project = Project.find(params[:projectId])
    if project
      render json: {result: true, project: project}
    else
      render json: {result: false, message: "can't find project"}
    end
  end

  def modifyTag
    tag = Tag.find(params[:tagId])
    if tag
      tag.update(name: params[:name], color: params[:color])
      tag.save
      render json: {result: true, tag: tag}
    else
      render json: {result: false, message: "can't find tag"}
    end
  end

  def deleteTag
    tag = Tag.find(params[:tagId])
    if tag
      tag.destroy
      render json: {result: true, message: 'success'}
    else
      render json: {result: false, message: "can't find tag"}
    end
  end

  def readNotifications
    user = User.find(params[:userId])
    if user
      if user.notification_order
        logger.info 'notificationCount = ' + user.notification_count.to_s
        notifications = NotificationController.readNotifications(user)
        render json: {result: true, notifications: notifications}
      else
        render json: {result: false, message: "no notifications"}
      end
    else
      render json: {result: false, message: "can't find user"}
    end
  end

  def readMyTasks
    user = User.find(params[:userId])
    if user
      if user.workers.count > 0
        mytasks = Array.new
        user.workers.each do |work|
          tag = nil
          if work.task.tags.count > 0
            tag = work.task.tags[0]
          end
          mytasks.push({'assigned_worker' => work.user.name, 'task' => work.task, 'tag' => tag})
        end
        render json: {result: true, count: user.workers.count, mytasks: mytasks}
      else
        render json: {result: true, count: user.workers.count}
      end
    else
      render json: {result: false, message: "can't find user"}
    end
  end

  def dashboard
  end
end

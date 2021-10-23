class TaskboardController < ApplicationController

  def self.checkWorkerInTask(user, task)
    if user and task.workers.exists?(user: user)
      return true
    end
    return false
  end

  def readTask
    task = Task.find(params[:taskId])
    if task
      worker = TaskboardController.checkWorkerInTask(User.find(params[:userId]), task)
      render json: {result: true, task: task, projectId: task.section.project.id, worker: worker}
    else
      render json: {result: false, message: "can't find task"}
    end

  end
  def renameSection
    section = Section.find(params[:sectionId])
    if section
      section.update(title: params[:title])
      section.save
      render json: {result: true, title: section.title}
    else
      render json: {result: false, message: "can't find section"}
    end
  end

  def createTask
    user = User.find(params[:userId])
    if user
      section = Section.find(params[:sectionId])
      if section
        task = Task.new(title: params[:title], desc: params[:desc], creator: user, section: section, dday: nil, checklist_order: nil, history_order: nil, comment_order: nil, state: 'created')
        task.save
        if section.order
          order = section.order + '-' + task.id.to_s
        else
          order = task.id.to_s
        end
        logger.info('order = ' + order)
        section.update(order: order)
        history = HistoryController.recordTask('create', user, task)
        if history['result']
          render json: {result: true, task: task}
        else
          render json: {result: false, message: history['message']}
        end
        # notification = NotificationController.recordTask('create', task, user)
        # logger.info(notification)
      else
        render json: {result: false, message: "can't find section"}
      end
    else
      render json: {result: false, message: "can't find user"}
    end
  end

  def deleteTask
    task = Task.find(params[:taskId])
    if task
      if task.tags
        task.tags.each do |tag|
          task.tags.delete tag
        end
      end
      section = task.section
      if section
        attachments = Array.new
        task.attachments.each do |attachment|
          attachments.push(attachment.name)
        end
        order = section.order.split('-') - [task.id.to_s]
        section.update(order: (order * '-').to_s)
        task.destroy
        render json: {result: true, section: section, attachments: attachments}
      else
        render json: {result: false, message: "can't find section"}
      end
    else
      render json: {result: false, message: "can't find task"}
    end
  end

  def finishTask
    task = Task.find(params[:taskId])
    if task
      task.update(state: 'completed')
      render json: {result: true, task: task}
    else
      render json: {result: false, message: "can't find task"}
    end
  end

  def orderTask
    section = Section.find(params[:sectionId])
    if section
      order = nil
      if params[:orders]
        params[:orders].each do |order|
          task = Task.find(order.to_i)
          task.update(section: section)
          task.save
        end
        order = (params[:orders] * "-").to_s
      end
      section.update(order: order)
      section.save
      render json: {result: true, section: section}
    else
      render json: {result: false, message: "can't find section"}
    end
  end

  def createSection
    project = Project.find(params[:projectId])
    if project
      section = Section.new(title: params[:title], project: project, order: nil, color: params[:color])
      section.save
      render json: {result: true, section: section}
    else
      render json: {result: false, message: "can't find project"}
    end
  end

  def modifySection
    section = Section.find(params[:sectionId])
    if section
      section.update(title: params[:title], color: params[:color])
      section.save
      render json: {result: true, section: section}
    else
      render json: {result: false, message: "can't find section"}
    end
  end

  def deleteSection
    section = Section.find(params[:sectionId])
    if section
      tasks = section.tasks
      if tasks
        tasks.each do |task|
          ApplicationController.deleteTaskTags(task)
        end
      end

      section.destroy
      render json: {result: true, message: 'success'}
    else
      render json: {result: false, message: "can't find section"}
    end
  end

  def renameTaskTitle
    task = Task.find(params[:taskId])
    if task
      task.update(title: params[:title])
      task.save
      render json: {result: true, title: task.title}
    else
      render json: {result: false, message: "can't find task"}
    end
  end
  def renameTaskDesc
    task = Task.find(params[:taskId])
    if task
      task.update(desc: params[:desc])
      task.save
      render json: {result: true, desc: task.desc}
    else
      render json: {result: false, message: "can't find task"}
    end
  end

  def modifyDday
    user = User.find(session[:user]['id'])
    if user
      task = Task.find(params[:taskId])
      if task
        task.update(dday: params[:dday])
        if task.save
          history = HistoryController.recordCalendar('modify', user, task)
          if history['result']
            render json: {result: true, dday: task.dday}
          else
            render json: {result: false, message: history['message']}
          end
          notification = NotificationController.recordCalendar('modify', task, user)
          logger.info(notification)
        else
          render json: {result: false, message: "failed to save dday"}
        end
      else
        render json: {result: false, message: "can't find task"}
      end
    else
      render json: {result: false, message: "can't find user"}
    end
  end

  def addTag
    project = Project.find(params[:projectId])
    if project
      tag = Tag.new(name: params[:name], color: params[:color], project: project)
      tag.save
      render json: {result: true, tag: tag}
    else
      render json: {result: false, message: "can't find project"}
    end
  end

  def readTags
    project = Project.find(params[:projectId])
    if project
      tags = Tag.where(project: project)
      render json: {result: true, tags: tags}
    else
      render json: {result: false, message: "can't find project"}
    end
  end

  def readAttachedTags
    task = Task.find(params[:taskId])
    if task
      render json: {result: true, tags: task.tags}
    else
      render json: {result: false, message: "can't find task"}
    end
  end

  def attachTag
    task = Task.find(params[:taskId])
    if task
      tag = Tag.find(params[:tagId])
      if tag
        attach = false
        if task.tags.exists?(id: tag.id) == false
          task.tags << tag
          attach = true
        end
        render json: {result: true, tag: tag, attached: attach}
      else
        render json: {result: false, message: "can't find tag"}
      end
    else
      render json: {result: false, message: "can't find task"}
    end
  end

  def detachTag
    task = Task.find(params[:taskId])
    if task
      tag = Tag.find(params[:tagId])
      if tag
        detach = false
        if task.tags.exists?(id: tag.id) == true
          task.tags.delete tag
          detach = true
        end
        render json: {result: true, tag: tag, detached: detach}
      else
        render json: {result: false, message: "can't find tag"}
      end
    else
      render json: {result: false, message: "can't find task"}
    end
  end

  def assignedWorker
    user = User.find(session[:user]['id'])
    if user
      task = Task.find(params[:taskId])
      if task
        member = User.find(params[:memberId])
        if member
          if Worker.exists?(task: task, user: member) == false
            worker = Worker.new(task: task, user: member)
            if worker.save
              history = HistoryController.recordWorker('assigned', user, task, worker)
              if history['result']
                render json: {result: true, worker: worker.user}
              else
                render json: {result: false, message: history['message']}
              end
              notification = NotificationController.recordWorker('assigned', task, user, worker)
              logger.info(notification)
            else
              render json: {result: false, message: "failed to save worker"}
            end
          else
            render json: {result: false, message: "already existed"}
          end
        else
          render json: {result: false, message: "can't find member"}
        end
      else
        render json: {result: false, message: "can't find task"}
      end
    else
      render json: {result: false, message: "can't find user"}
    end
  end

  def unassignedWorker
    user = User.find(session[:user]['id'])
    if user
      task = Task.find(params[:taskId])
      if task
        member = User.find(params[:memberId])
        if member
          unassigned = false
          if Worker.exists?(task: task, user: member)
            worker = Worker.find_by(task: task, user: member)
            history = HistoryController.recordWorker('unassigned', user, task, worker)
            if history['result']
              worker.destroy
              unassigned = true
            else
              render json: {result: false, message: history['message']}
            end
          end
          render json: {result: true, name: user.name, unassigned: unassigned}
        else
          render json: {result: false, message: "can't find member"}
        end
      else
        render json: {result: false, message: "can't find task"}
      end
    else
      render json: {result: false, message: "can't find user"}
    end
  end

  def readWorkers
    task = Task.find(params[:taskId])
    if task
      render json: {result: true, count: task.assigned_workers.count, assignedWorkers: task.assigned_workers, state: task.state}
    else
      render json: {result: false, message: "can't find task"}
    end
  end

  def assignedWatcher
    task = Task.find(params[:taskId])
    if task
      member = User.find(params[:memberId])
      if member
        if Watcher.exists?(task: task, user: member) == false
          watcher = Watcher.new(task: task, user: member)
          watcher.save
          render json: {result: true, watcher: watcher.user}
        else
          render json: {result: false, message: "already existed"}
        end
      else
        render json: {result: false, message: "can't find member"}
      end
    else
      render json: {result: false, message: "can't find task"}
    end
  end
  def unassignedWatcher
    task = Task.find(params[:taskId])
    if task
      member = User.find(params[:memberId])
      if member
        unassigned = false
        if Watcher.exists?(task: task, user: member)
          watcher = Watcher.find_by(task: task, user: member)
          watcher.destroy
          unassigned = true
        end
        render json: {result: true, name: user.name, unassigned: unassigned}
      else
        render json: {result: false, message: "can't find member"}
      end
    else
      render json: {result: false, message: "can't find task"}
    end
  end
  def readWatchers
    task = Task.find(params[:taskId])
    if task
      render json: {result: true, count: task.assgined_watchers.count, assignedWatchers: task.assgined_watchers}
    else
      render json: {result: false, message: "can't find task"}
    end
  end

  def createChecklist
    user = User.find(params[:userId])
    if user
      task = Task.find(params[:taskId])
      if task
        checklist = Checklist.new(task: task, content: params[:content], strikeout: false)
        if checklist.save
          if task.checklist_order
            order = task.checklist_order + '-' + checklist.id.to_s
            logger.info(order)
            task.update(checklist_order: order)
            task.save
          else
            task.update(checklist_order: checklist.id.to_s)
            task.save
          end
          task.update(checklist_count: task.checklist_count+1)
          history = HistoryController.recordChecklist('create', user, checklist.task, checklist)
          if history['result']
            render json: {result: true, checklist: checklist}
          else
            render json: {result: false, message: history['message']}
          end
          notification = NotificationController.recordChecklist('create', task, user, checklist)
          logger.info(notification)
        else
          render json: {result: false, message: "failed save checklist"}
        end
      else
        render json: {result: false, message: "can't find task"}
      end
    else
      render json: {result: false, message: "can't find user"}
    end
  end

  def deleteChecklist
    user = User.find(params[:userId])
    if user
      task = Task.find(params[:taskId])
      if task
        checklist = Checklist.find_by(id: params[:checklistId], task: task)
        if checklist
          orders = task.checklist_order.split('-') - [checklist.id.to_s]
          task.update(checklist_order: (orders * '-').to_s)
          task.update(checklist_count: task.checklist_count-1)
          history = HistoryController.recordChecklist('delete', user, task, checklist)
          if history['result']
            checklist.destroy
            render json: {result: true}
          else
            render json: {result: false, message: history['message']}
          end
        else
          render json: {result: false, message: "can't find checklist"}
        end
      else
        render json: {result: false, message: "can't find task"}
      end
    else
      render json: {result: false, message: "can't find user"}
    end
  end

  def strikeoutChecklist
    user = User.find(params[:userId])
    if user
      task = Task.find(params[:taskId])
      if task
        checklist = Checklist.find_by(id: params[:checklistId], task: task)
        if checklist
          strikeout = params[:strikeout] == 'true' ? true : false
          checklist.update(strikeout: strikeout)
          if checklist.save
            if strikeout == true
              task.update(strikeout_count: task.strikeout_count+1)
              history = HistoryController.recordChecklist('modify', user, task, checklist)
              if history['result']
                render json: {result: true, checklist: checklist}
              else
                render json: {result: true, message: history['message']}
              end
            else
              task.update(strikeout_count: task.strikeout_count-1)
              render json: {result: true, checklist: checklist}
            end
          end
        else
          render json: {result: false, message: "can't find checklist"}
        end
      else
        render json: {result: false, message: "can't find task"}
      end
    else
      render json: {result: false, message: "can't find user"}
    end
  end

  def readChecklists
    task = Task.find(params[:taskId])
    if task
      checklists = Array.new
      if task.checklist_order
        orders = task.checklist_order.split('-')
        orders.each do |order|
          checklists.push(Checklist.find(order.to_i))
        end
      end
      worker = TaskboardController.checkWorkerInTask(User.find(params[:userId]), task)
      render json: {result: true, checklists: checklists, worker: worker}
    else
      render json: {result: false, message: "can't find task"}
    end
  end

  def createComment
    user = User.find(params[:userId])
    if user
      task = Task.find(params[:taskId])
      if task
        comment = Comment.new(user: user, task: task, content: params[:content])
        if comment.save
          if task.comment_order
            order = comment.id.to_s + '-' + task.comment_order
            logger.info(order)
            task.update(comment_order: order)
            task.save
          else
            task.update(comment_order: comment.id.to_s)
            task.save
          end
          task.update(comment_count: task.comment_count+1)
          history = HistoryController.recordComment('create', comment.user, comment.task, comment)
          if history['result']
            render json: {result: true, userId: user.id, userName: user.name, avatar: user.avatar, comment: comment}
          else
            render json: {result: false, message: history['message']}
          end
          notification = NotificationController.recordComment('create', task, user, comment)
          logger.info(notification)
        else
          render json: {result: false, message: "failed save comment"}
        end
      else
        render json: {result: false, message: "can't find task"}
      end
    else
      render json: {result: false, message: "can't find user"}
    end
  end
  def modifyComment
    comment = Comment.find(params[:commentId])
    if comment
      comment.update(content: params[:content])
      history = HistoryController.recordComment('modify', comment.user, comment.task, comment)
      if history['result']
        render json: {result: true, comment: comment}
      else
        render json: {result: false, message: history['message']}
      end
    else
      render json: {result: false, message: "can't find comment"}
    end
  end

  def deleteComment
    task = Task.find(params[:taskId])
    if task
      comment = Comment.find(params[:commentId])
      if comment
        orders = task.comment_order.split('-') - [comment.id.to_s]
        task.update(comment_order: (orders * '-').to_s)
        task.update(comment_count: task.comment_count-1)
        history = HistoryController.recordComment('delete', comment.user, comment.task, comment)
        if history['result']
          comment.destroy
          render json: {result: true}
        else
          render json: {result: false, message: history['message']}
        end
      else
        render json: {result: false, message: "can't find comment"}
      end
    else
      render json: {result: false, message: "can't find task"}
    end
  end

  def readComments
    task = Task.find(params[:taskId])
    if task
      comments = Array.new
      if task.comment_order
        orders = task.comment_order.split('-')
        offset = params[:offset].to_i
        count = params[:count].to_i
        if offset < orders.count
          if offset+count > orders.count
            count = orders.count-offset
          end
          count.times do
            comment = Comment.find(orders[offset].to_i)
            if comment
              comments.push({'userId' => comment.user.id, 'name' => comment.user.name, 'avatar' => comment.user.avatar, 'comment' => comment})
            end
            offset+=1
          end
        end
        # orders.each do |order|
        #   comment = Comment.find(order.to_i)
        #   comments.push({'userId' => comment.user.id, 'name' => comment.user.name, 'avatar' => comment.user.avatar, 'comment' => comment})
        # end
      end
      render json: {result: true, comments: comments}
    else
      render json: {result: false, message: "can't find task"}
    end
  end

  def readCommentCount
    task = Task.find(params[:taskId])
    if task
      render json: {result: true, commentCount: task.comment_count}
    else
      render json: {result: false}
    end
  end

  def readHistories
    task = Task.find(params[:taskId])
    if task
      if task.history_order
        histories = HistoryController.readTaskHistories(task, params[:offset].to_i, params[:count].to_i)
        render json: {result: true, histories: histories}
      else
        render json: {result: false, message: "no histories"}
      end
    else
      render json: {result: false, message: "can't find task"}
    end
  end

  def readHistoryCount
    task = Task.find(params[:taskId])
    if task
      render json: {result: true, historyCount: task.history_count}
    else
      render json: {result: false}
    end
  end

  def createAttachments
    task = Task.find(params[:taskId])
    if task
      user = User.find(params[:userId])
      if user
        attachmentCount=0
        representAttachment = nil
        appendedAttachments = Array.new()
        params[:attachments].each do |attachment|
          newAttachment = Attachment.new(task: task, user: user, kind: attachment[1]['kind'], name: attachment[1]['name'], original: attachment[1]['original'], thumb: attachment[1]['thumb'])
          newAttachment.save
          appendedAttachments.push(newAttachment)
          attachmentCount += 1
          if representAttachment.nil?
            representAttachment = newAttachment
          end
        end
        if representAttachment
          HistoryController.recordAttachment('create', user, task, representAttachment, attachmentCount)
          NotificationController.recordAttachment('create', task, user, representAttachment, attachmentCount)
          render json: {result: true, message: 'success', appendedAttachments: appendedAttachments}
        else
          render json: {result: false, message: "can't save attachments"}
        end

        # attachmentCount=0
        # representAttachment = nil
        # params[:attachments].each do |attachment|
        #   newAttachment = Attachment.new(task: task, user: user, kind: attachment[1]['kind'], name: attachment[1]['name'], original: attachment[1]['original'], thumb: attachment[1]['thumb'])
        #   newAttachment.save
        #   attachmentCount += 1
        #   if representAttachment.nil?
        #     representAttachment = {id: newAttachment.id, content: newAttachment.name + '/'}
        #   end
        # end
        # if representAttachment
        #   representAttachment[:content] += attachmentCount.to_s
        #   HistoryController.recordAttachment('create', user, task, representAttachment)
        #   NotificationController.recordAttachment('create', task, user, representAttachment)
        #   render json: {result: true, message: 'success'}
        # else
        #   render json: {result: false, message: "can't save attachments"}
        # end
        # render json: {result: true, message: 'success'}
      else
        render json: {result: false, message: "can't find user"}
      end
    else
      render json: {result: false, message: "can't find task"}
    end
  end
  def readAttachments
    task = Task.find(params[:taskId])
    if task
      render json: {result: true, attachments: task.attachments}
    else
      render json: {result: false, message: "can't find task"}
    end
  end
  def deleteAttachment
    attachment = Attachment.find(params[:attachmentId])
    if attachment
      history = HistoryController.recordAttachment('delete', attachment.user, attachment.task, attachment, 1)
      if history['result']
        attachment.destroy
        render json: {result: true}
      else
        render json: {result: false, message: history['message']}
      end
    end
  end
  def updateProgress
    task = Task.find(params[:taskId])
    if task
      user = User.find(params[:userId])
      if user
        task.update(progress: params[:progress])
        render json: {result: true, progress: task.progress}
      else
        render json: {result: false, message: "can't find user"}
      end
    else
      render json: {result: false, message: "can't find task"}
    end
  end

  def taskboard
    @editor = false
    @project = Project.find(params[:projectId])
    user = User.find(session[:user]['id'])
    if user
      roles = ProjectMember.where(user: user, project: @project)
      if roles.length > 0
        @myRolesInProject = Array.new
        roles.each do |role|
          @myRolesInProject.push(role.roletype)
          if role.roletype.name == 'administrator' or role.roletype.name == 'manager'
            @editor = true
          end
        end
        #read myProjects and belong to projects
        @dropdownMyProjects = Project.where(creator: user).where.not(id: @project.id)
        @dropdownBelongToProjects = user.belong_projects.where.not(id: @project.id, creator: user)
      else
        redirect_back(fallback_location: root_path)
      end
    else
      redirect_back(fallback_location: root_path)
    end
  end
end

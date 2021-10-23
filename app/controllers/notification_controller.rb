class NotificationController < ApplicationController

  @@invKinds = {'0' => 'calendar', '1' => 'worker', '2' => 'watcher', '3' => 'tag', '4' => 'comment', '5' => 'checklist', '6' => 'attachment', '7' => 'task'}
  @@invAttrs = {'0' => 'create', '1' => 'modify', '2' => 'delete', '3' => 'assigned', '4' => 'unassigned', '5' => 'completed'}

  @@kinds = {'calendar' => 0, 'worker' => 1, 'watcher' => 2, 'tag' => 3, 'comment' => 4, 'checklist' => 5, 'attachment' => 6, 'task' => 7}
  @@attrs = {'create' => 0, 'modify' => 1, 'delete' => 2, 'assigned' => 3, 'unassigned' => 4, 'completed' => 5}

  def self.recordWorker(attr, task, player, worker)
    notification = Notification.new(user: worker.user, task: task, player: player, kind: @@kinds['worker'], attr: @@attrs[attr], content: worker.user.name)
    result = postprocess(notification)
    if result['result'] == false
      return {'result' => false, 'message' => result['message'] + ' : workerId = ' + worker.id }
    end
    return {'result' => true, 'message' => "success"}
  end

  def self.recordCalendar(attr, task, player)
    if task.assigned_workers.count > 0
      task.assigned_workers.each do |worker|
        notification = Notification.new(user: worker, task: task, player: player, kind: @@kinds['calendar'], attr: @@attrs[attr], content: task.dday)
        result = postprocess(notification)
        if result['result'] == false
          return {'result' => false, 'message' => result['message'] + ' : workerId = ' + worker.id }
        end
      end
    end
    return {'result' => true, 'message' => "success"}
  end

  def self.recordChecklist(attr, task, player, checklist)
    if task.assigned_workers.count > 0
      task.assigned_workers.each do |worker|
        notification = Notification.new(user: worker, task: task, player: player, kind: @@kinds['checklist'], attr: @@attrs[attr], content: checklist.content)
        result = postprocess(notification)
        if result['result'] == false
          return {'result' => false, 'message' => result['message'] + ' : workerId = ' + worker.id }
        end
      end
    end
    return {'result' => true, 'message' => "success"}
  end

  def self.recordComment(attr, task, player, comment)
    if task.assigned_workers.count > 0
      if player.id == task.creator.id #task creator가 코멘트 작성한 경우
        task.assigned_workers.each do |worker|
          notification = Notification.new(user: worker, task: task, player: player, kind: @@kinds['comment'], attr: @@attrs[attr], content: comment.content)
          result = postprocess(notification)
          if result['result'] == false
            return {'result' => false, 'message' => result['message'] + ' : workerId = ' + worker.id }
          end
        end
      else #작업자가 코멘트 작성한 경우
        notification = Notification.new(user: task.creator, task: task, player: player, kind: @@kinds['comment'], attr: @@attrs[attr], content: comment.content)
        result = postprocess(notification)
        if result['result'] == false
          return {'result' => false, 'message' => result['message'] + ' : creatorId = ' + task.creator.id }
        end
        task.assigned_workers.each do |worker|
          if player.id != worker.id
            notification = Notification.new(user: worker, task: task, player: player, kind: @@kinds['comment'], attr: @@attrs[attr], content: comment.content)
            result = postprocess(notification)
            if result['result'] == false
              return {'result' => false, 'message' => result['message'] + ' : workerId = ' + worker.id }
            end
          end
        end
      end
    end
    return {'result' => true, 'message' => "success"}
  end

  def self.recordAttachment(attr, task, player, attachment, attachmentCount)
    if task.assigned_workers.count > 0
      if player.id == task.creator.id #task creator가 attachment 작성한 경우
        task.assigned_workers.each do |worker|
          notification = Notification.new(user: worker, task: task, player: player, kind: @@kinds['attachment'], attr: @@attrs[attr], content: attachment.name + '/' + attachmentCount.to_s)
          result = postprocess(notification)
          if result['result'] == false
            return {'result' => false, 'message' => result['message'] + ' : workerId = ' + worker.id }
          end
        end
      else # 작업자가 attachment 작성한 경우
        notification = Notification.new(user: task.creator, task: task, player: player, kind: @@kinds['attachment'], attr: @@attrs[attr], content: attachment.name + '/' + attachmentCount.to_s)
        result = postprocess(notification)
        if result['result'] == false
          return {'result' => false, 'message' => result['message'] + ' : creatorId = ' + task.creator.id }
        end
        task.assigned_workers.each do |worker|
          if player.id != worker.id
            notification = Notification.new(user: worker, task: task, player: player, kind: @@kinds['attachment'], attr: @@attrs[attr], content: attachment.name + '/' + attachmentCount.to_s)
            result = postprocess(notification)
            if result['result'] == false
              return {'result' => false, 'message' => result['message'] + ' : workerId = ' + worker.id }
            end
          end
        end
      end
    end
    return {'result' => true, 'message' => "success"}
  end

  def self.recordTask(attr, task, player)
    if task.assigned_workers.count > 0
      task.assigned_workers.each do |worker|
        notification = Notification.new(user: worker, task: task, player: player, kind: @@kinds['task'], attr: @@attrs[attr], content: task.id)
        result = postprocess(notification)
        if result['result'] == false
          return {'result' => false, 'message' => result['message'] + ' : workerId = ' + worker.id }
        end
      end
    end
    return {'result' => true, 'message' => "success"}
  end

  def self.postprocess(notification)
    if notification.save
      userNotification = updateNotification(notification.user, notification.id.to_s)
      if userNotification
        return {'result' => true, 'message' => "success"}
      else
        return {'result' => false, 'message' => "failed to save userNotification"}
      end
    end
    return {'result' => false, 'message' => "failed to save notification"}
  end

  def self.updateNotification(user, id)
    if user.notification_order
      order = user.notification_order + '-' + id
      user.update(notification_order: order)
      user.update(notification_count: user.notification_count+1)
      return true
    else
      user.update(notification_order: id)
      user.update(notification_count: user.notification_count+1)
      return true
    end
    return false
  end

  def self.deleteNotification(user, id)
    notification = Notification.find(id)
    if notification
      orders = user.notification_order.split('-') - [id]
      user.update(notification_order: (orders * '-').to_s)
      user.update(notification_count: user.notification_count-1)
      notification.destroy
      return {'result' => true, 'message' => "destroyed notification successfully"}
    else
      return {'result' => false, 'message' => "can't find notification"}
    end
  end

  def self.readNotifications(user)
    logger.info 'self.readNotifications(user)'
    notifications = Array.new
    reorders = nil
    orders = user.notification_order.split('-')
    orders.each do |order|
      if Notification.exists?(id: order.to_i)
        notification = Notification.find(order.to_i)
        notifications.push({'playerName' => notification.player.name, 'notification' => notification})
      else
        reorders = (reorders.nil? ? orders : reorders) - [order]
      end
    end
    unless reorders.nil?
      user.update(notification_order: (reorders * '-').to_s)
      user.update(notification_count: user.notification_count-1)
    end
    return notifications
  end

  # self를 사용하게 되면 class method 가 되고,
  # 없다면 instance method 가 되어 클래스가 인스턴스가 된후에 사용할 수 있다.
  def self.invKinds
    kinds = Array.new
    @@invKinds.each do |kind|
      kinds.push(kind.second)
    end
    return kinds
  end

  def deleteNotification
    notification = Notification.find(params[:notificationId])
    if notification
      notification.destroy
      render json: {result: false, message: "deleted notification successfully!"}
    else
      render json: {result: false, message: "can't find notification"}
    end
  end

end
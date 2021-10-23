class HistoryController < ApplicationController

  @@invKinds = {'0' => 'calendar', '1' => 'worker', '2' => 'watcher', '3' => 'tag', '4' => 'comment', '5' => 'checklist', '6' => 'attachment', '7' => 'task'}
  @@invAttrs = {'0' => 'create', '1' => 'modify', '2' => 'delete', '3' => 'assigned', '4' => 'unassigned', '5' => 'completed'}

  @@kinds = {'calendar' => 0, 'worker' => 1, 'watcher' => 2, 'tag' => 3, 'comment' => 4, 'checklist' => 5, 'attachment' => 6, 'task' => 7}
  @@attrs = {'create' => 0, 'modify' => 1, 'delete' => 2, 'assigned' => 3, 'unassigned' => 4, 'completed' => 5}

  public

  def self.recordWorker(attr, user, task, worker)
    history = History.new(user: user, task: task, kind: @@kinds['worker'], attr: @@attrs[attr], content: worker.user.name, ref: worker.id)
    return postprocess(task, history)
  end
  def self.recordCalendar(attr, user, task)
    history = History.new(user: user, task: task, kind: @@kinds['calendar'], attr: @@attrs[attr], content: task.dday, ref: task.id)
    return postprocess(task, history)
  end
  def self.recordChecklist(attr, user, task, checklist)
    history = History.new(user: user, task: task, kind: @@kinds['checklist'], attr: @@attrs[attr], content: checklist.content, ref: checklist.id)
    return postprocess(task, history)
  end
  def self.recordComment(attr, user, task, comment)
    history = History.new(user: user, task: task, kind: @@kinds['comment'], attr: @@attrs[attr], content: comment.content, ref: comment.id)
    return postprocess(task, history)
  end
  def self.recordAttachment(attr, user, task, attachment, attachmentCount)
    history = History.new(user: user, task: task, kind: @@kinds['attachment'], attr: @@attrs[attr], content: attachment.name + '/' + attachmentCount.to_s, ref: attachment.id)
    return postprocess(task, history)
  end
  def self.recordTask(attr, user, task)
    history = History.new(user: user, task: task, kind: @@kinds['task'], attr: @@attrs[attr], content: task.id, ref: task.id)
    return postprocess(task, history)
  end

  private
  def self.postprocess(task, history)
    if history.save
      taskHistory = updateTaskHistory(task, history.id.to_s)
      if taskHistory
        return {'result' => true, 'message' => "success"}
      else
        return {'result' => false, 'message' => "failed to save taskHistory"}
      end
    end
    return {'result' => false, 'message' => "failed to save history"}
  end
  def self.updateTaskHistory(task, id)
    if task.history_order
      order = id + '-' + task.history_order
      task.update(history_order: order, history_count: task.history_count+1)
      return true
    else
      task.update(history_order: id, history_count: task.history_count+1)
      return true
    end
    return false
  end
  def self.deleteTaskHistory(task, id)
    history = History.find(id)
    if history
      orders = task.history_order.split('-') - [id]
      task.update(history_order: (orders * '-').to_s)
      task.update(history_count: task.history_count-1)
      History.find(id).destroy
      return {'result' => true, 'message' => "destroyed notification successfully"}
    else
      return {'result' => false, 'message' => "can't find notification"}
    end
  end
  public
  # def self.readTaskHistories(task)
  #   histories = Array.new
  #   orders = task.history_order.split('-')
  #   orders.each do |order|
  #     history = History.find(order.to_i)
  #     histories.push({'name' => history.user.name, 'avatar' => history.user.avatar, 'kind' => @@invKinds[history.kind.to_s], 'attr' => @@invAttrs[history.attr.to_s], 'history' => history})
  #   end
  #   return histories
  # end
  def self.readTaskHistories(task, offset, count)
    histories = Array.new
    orders = task.history_order.split('-')
    if offset < orders.count
      if offset+count > orders.count
        count = orders.count-offset
      end
      count.times do
        history = History.find(orders[offset].to_i)
        if history
          histories.push({'name' => history.user.name, 'avatar' => history.user.avatar, 'kind' => @@invKinds[history.kind.to_s], 'attr' => @@invAttrs[history.attr.to_s], 'history' => history})
        end
        offset+=1
      end
    end
    return histories
  end

  public
  # def self.getKind(num)
  #   return @@invKinds[num]
  # end
  # def self.getAttr(num)
  #   return @@invAttrs[num]
  # end
  def self.getKindIndex(kind)
    return @@kinds[kind]
  end
  def self.getAttrIndex(attr)
    return @@attrs[attr]
  end

  def self.invKinds
    kinds = Array.new
    @@invKinds.each do |kind|
      kinds.push(kind.second)
    end
    return kinds
  end
  def self.attrs
    return @@attrs
  end

  def self.test(kind, attr, commentId)
    whatKind = @@kinds[kind]
    whatAttr = @@attrs[attr]
    logger.info(whatKind)
    logger.info(whatAttr)

    comment = Comment.find(commentId)
    logger.info(comment.content)

  end
end
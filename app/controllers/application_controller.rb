class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :detect_locale
  before_action :preAction
  before_action :checkInfomation

  def preAction
    return if request.post?

    @primaryColor = '#ffc107'
    url = request.url.split('/')
    @request_ctl = url[url.length-2]
    @request_url = url.last.split('?').first
  end

  def detect_locale
    I18n.locale = request.headers['Accept-Language'].scan(/\A[a-z]{2}/).first
  end

  def checkInfomation
    @userAgent = request.user_agent
    @mobileDevice = ApplicationController.checkMobileDevice(@userAgent)
    @browserInfo = ApplicationController.getBrowserInfo(@userAgent)
  end

  # common fuctions
  #
  def self.checkMobileDevice(userAgent)
    if userAgent =~ /Android/i or userAgent =~ /iPhone/i
      return true
    end
    return false
  end
  def self.getBrowserInfo(userAgent)
    if userAgent =~ /Chrome/i
      return 'Chrome'
    elsif userAgent =~ /Safari/i
      return 'Safari'
    elsif userAgent =~ /Firefox/i
      return 'Firefox'
    else
      return nil
    end
  end

  def self.getAllTasks(project)
    tasks = Array.new
    project.sections.each do |section|
      section.tasks.each do |task|
        tasks.push(task)
      end
    end
    return tasks
  end

  def self.deleteTaskTags(task)
    if task.tags
      task.tags.each do |tag|
        task.tags.delete tag
      end
    end
  end

  def self.cleanupSection(section)
    tasks = section.tasks
    if tasks
      tasks.each do |task|
        deleteTaskTags(task)
      end
    end
  end

  def self.cleanupProjectBeforeDestroy(project)
    sections = project.sections
    if sections
      sections.each do |section|
        cleanupSection(section)
      end
    end
  end

  def self.cleanupUserBeforeDestroy(userId)
    user = User.find(userId)
    withdrawUser = User.find_by(account: 'withdraw@daldaltask.com')
    if user.comments
      comments = user.comments
      comments.each do |comment|
        comment.update(user: withdrawUser)
        histories = History.where(user: user, task: comment.task, ref: comment.id)
        if histories
          histories.each do |history|
            history.update(user: withdrawUser)
          end
        end
      end
    end
    if user.tasks
      tasks = user.tasks
      tasks.each do |task|
        task.update(creator: withdrawUser)
        kind = HistoryController.getKindIndex('task')
        attr = HistoryController.getAttrIndex('create')
        history = History.find_by(user: user, task: task, kind: kind, attr: attr)
        if history
          history.update(user: withdrawUser)
        end
      end
    end

    notifications = Notification.where(player: user)
    if notifications
      notifications.each do |notification|
        notification.update(player: withdrawUser)
      end
    end

  end

end

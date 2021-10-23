class TableviewController < ApplicationController

  def self.readMembers(project)
    members = Array.new
    project.project_members.each do |member|
      members.push(member.user)
    end
    return members
  end

  def readMemberTasks
    user = User.find(params[:userId])
    if user
      underwayTasks = Array.new
      completedTasks = Array.new
      user.workers.each do |worker|
        if worker.task.section.project.id.to_s == params[:projectId]
          if worker.task.state == 'completed'
            completedTasks.push(worker.task)
          else
            underwayTasks.push(worker.task)
          end
        end
      end
      render json: {result: true, user: user, underwayTasks: underwayTasks, completedTasks: completedTasks}
    else
      render json: {result: false, message: "can't find user"}
    end
  end

  def tableView
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

        @members = TableviewController.readMembers(@project)

        @tasks = ApplicationController.getAllTasks(@project)
        @tasks.each do |task|
          if task.dday
            logger.info "task title = " + task.title + ", dday = " + task.dday
          end
        end

      else
        redirect_back(fallback_location: root_path)
      end
    else
      redirect_back(fallback_location: root_path)
    end
  end
end

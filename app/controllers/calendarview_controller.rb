class CalendarviewController < ApplicationController
  def calendarView
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

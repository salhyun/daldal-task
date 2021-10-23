class ProjectMember < ApplicationRecord
  belongs_to :project
  belongs_to :user
  belongs_to :roletype
end

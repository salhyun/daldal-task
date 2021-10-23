class Contribution < ApplicationRecord
  belongs_to :project
  belongs_to :user
  belongs_to :task
end

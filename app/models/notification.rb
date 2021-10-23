class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :player, class_name: 'User'
  belongs_to :task
end

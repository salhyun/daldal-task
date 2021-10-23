class Group < ApplicationRecord
  belongs_to :creator, class_name: 'User'
  has_many :group_members, dependent: :destroy
  has_many :users, through: :group_members
end

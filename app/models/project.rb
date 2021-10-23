class Project < ApplicationRecord
  has_many :project_members, dependent: :destroy
  has_many :users, through: :project_members
  belongs_to :creator, class_name: 'User'
  has_many :tags, dependent: :destroy
  has_many :sections, dependent: :destroy
  has_many :contributions, dependent: :destroy
end

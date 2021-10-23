class User < ApplicationRecord
  # mount_uploader :avatar, AvatarUploader
  has_many :project_members, dependent: :destroy
  has_many :belong_projects, through: :project_members, :source => :project
  has_many :groups, :foreign_key => 'creator_id', dependent: :destroy
  has_many :invitations, :foreign_key => 'requestor_id', dependent: :destroy
  has_many :accepters, through: :invitations, :foreign_key => 'accepter_id'
  has_many :projects, :foreign_key => 'creator_id', dependent: :destroy
  has_many :workers, dependent: :destroy
  has_many :watchers, dependent: :destroy
  has_many :tasks, :foreign_key => 'creator_id', dependent: :destroy
  has_many :comments
  has_many :histories
  has_many :notifications, dependent: :destroy
end

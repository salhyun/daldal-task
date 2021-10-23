class Task < ApplicationRecord
  has_many :checklists, dependent: :destroy
  belongs_to :creator, class_name: 'User'
  belongs_to :section
  has_and_belongs_to_many :tags
  has_many :workers, dependent: :destroy
  has_many :assigned_workers, through: :workers, :source => :user
  has_many :watchers, dependent: :destroy
  has_many :assgined_watchers, through: :watchers, :source => :user
  has_many :comments, dependent: :destroy
  has_many :histories, dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_many :attachments, dependent: :destroy
end

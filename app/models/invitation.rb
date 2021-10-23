class Invitation < ApplicationRecord
  belongs_to :requestor, class_name: 'User'
  belongs_to :accepter, class_name: 'User'
end

require "administrate/base_dashboard"

class UserDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    project_members: Field::HasMany,
    belong_projects: Field::HasMany.with_options(class_name: "Project"),
    groups: Field::HasMany,
    invitations: Field::HasMany,
    accepters: Field::HasMany.with_options(class_name: "User"),
    projects: Field::HasMany,
    workers: Field::HasMany,
    watchers: Field::HasMany,
    tasks: Field::HasMany,
    comments: Field::HasMany,
    histories: Field::HasMany,
    notifications: Field::HasMany,
    id: Field::Number,
    account: Field::String,
    password: Field::String,
    name: Field::String,
    avatar: Field::String,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    verified: Field::Boolean,
    secure_code: Field::String,
    notification_count: Field::Number,
    notification_order: Field::Text,
    state: Field::String,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = %i[
  id
  account
  name
  verified
  notification_count
  state
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
  id
  account
  password
  name
  avatar
  created_at
  updated_at
  verified
  secure_code
  projects
  notification_count
  notification_order
  tasks
  comments
  histories
  notifications
  project_members
  belong_projects
  groups
  invitations
  accepters
  workers
  watchers
  state
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[
  id
  account
  password
  name
  avatar
  created_at
  updated_at
  verified
  secure_code
  projects
  notification_count
  notification_order
  tasks
  comments
  histories
  notifications
  project_members
  belong_projects
  groups
  invitations
  accepters
  workers
  watchers
  state
  ].freeze

  # COLLECTION_FILTERS
  # a hash that defines filters that can be used while searching via the search
  # field of the dashboard.
  #
  # For example to add an option to search for open resources by typing "open:"
  # in the search field:
  #
  #   COLLECTION_FILTERS = {
  #     open: ->(resources) { where(open: true) }
  #   }.freeze
  COLLECTION_FILTERS = {}.freeze

  # Overwrite this method to customize how users are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(user)
  #   "User ##{user.id}"
  # end
end

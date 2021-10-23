require "administrate/base_dashboard"

class TaskDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    checklists: Field::HasMany,
    creator: Field::BelongsTo.with_options(class_name: "User"),
    section: Field::BelongsTo,
    tags: Field::HasMany,
    workers: Field::HasMany,
    assigned_workers: Field::HasMany.with_options(class_name: "User"),
    watchers: Field::HasMany,
    assgined_watchers: Field::HasMany.with_options(class_name: "User"),
    comments: Field::HasMany,
    histories: Field::HasMany,
    notifications: Field::HasMany,
    attachments: Field::HasMany,
    id: Field::Number,
    title: Field::String,
    desc: Field::Text,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    creator_id: Field::Number,
    dday: Field::String,
    checklist_order: Field::String,
    history_order: Field::Text,
    comment_order: Field::Text,
    comment_count: Field::Number,
    checklist_count: Field::Number,
    strikeout_count: Field::Number,
    history_count: Field::Number,
    progress: Field::Number,
    state: Field::String,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = %i[
  id
  title
  desc
  section
  comment_count
  history_count
  state
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
  checklists
  creator
  section
  tags
  workers
  assigned_workers
  watchers
  assgined_watchers
  comments
  histories
  notifications
  attachments
  id
  title
  desc
  created_at
  updated_at
  creator_id
  dday
  checklist_order
  history_order
  comment_order
  comment_count
  checklist_count
  strikeout_count
  history_count
  progress
  state
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[
  checklists
  creator
  section
  tags
  workers
  assigned_workers
  watchers
  assgined_watchers
  comments
  histories
  notifications
  attachments
  title
  desc
  creator_id
  dday
  checklist_order
  history_order
  comment_order
  comment_count
  checklist_count
  strikeout_count
  history_count
  progress
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

  # Overwrite this method to customize how tasks are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(task)
  #   "Task ##{task.id}"
  # end
end

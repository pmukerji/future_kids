class RelationLog < ActiveRecord::Base
  belongs_to :kid
  belongs_to :user

  default_scope { order(:created_at) }
end

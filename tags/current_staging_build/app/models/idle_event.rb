class IdleEvent < ActiveRecord::Base
  belongs_to :reading
  belongs_to :device
  include ApplicationHelper
end

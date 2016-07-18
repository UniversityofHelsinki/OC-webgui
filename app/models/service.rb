class Service < ActiveRecord::Base
  belongs_to :team
  has_many :queue_items
end

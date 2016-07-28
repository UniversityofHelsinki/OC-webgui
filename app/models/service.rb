class Service < ActiveRecord::Base
  belongs_to :team
  has_many :contacts, dependent: :destroy
  has_many :queue_items, dependent: :destroy
end

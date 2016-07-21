class Team < ActiveRecord::Base
  has_many :agents
  has_many :services
  has_many :queue_items, through: :services

  validates :name, uniqueness: true
end

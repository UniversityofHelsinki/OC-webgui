class Team < ActiveRecord::Base
  has_many :agents, dependent: :destroy
  has_many :services, dependent: :destroy
  has_many :queue_items, through: :services

  validates :name, uniqueness: true
end

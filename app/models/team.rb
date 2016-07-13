class Team < ActiveRecord::Base
  has_many :agents
  has_many :services

  validates :name, uniqueness: true
end

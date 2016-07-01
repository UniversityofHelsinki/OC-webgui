class State < ActiveRecord::Base
  validates :name, uniqueness: true
end

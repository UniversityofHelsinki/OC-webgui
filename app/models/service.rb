class Service < ActiveRecord::Base
  belongs_to :team
  has_many :contacts
end

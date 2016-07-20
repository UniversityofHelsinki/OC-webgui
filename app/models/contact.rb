class Contact < ActiveRecord::Base
  belongs_to :agent
  belongs_to :service
  has_one :team, through: :service

  validates :ticket_id, presence: true, uniqueness: true
end

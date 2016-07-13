class Contact < ActiveRecord::Base
  validates :ticket_id, presence: true, uniqueness: true
end

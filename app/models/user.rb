class User < ActiveRecord::Base
  has_secure_password
  belongs_to :agent
end

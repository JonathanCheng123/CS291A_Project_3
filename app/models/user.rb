class User < ApplicationRecord
    # Adds methods to set and authenticate against a BCrypt password
    has_secure_password
  
    # Validations
    validates :username, presence: true, uniqueness: true
    validates :password, presence: true, length: { minimum: 6 }, on: :create
  end
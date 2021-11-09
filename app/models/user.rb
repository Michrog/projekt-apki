class User < ApplicationRecord
  validates :name, presence: true, uniqueness: true, length: { in: 3..50 }
  validates :user_index, presence: true, uniqueness: true, length: { is: 6 }
  validates :password, presence: true, length: { minimum: 6 }
  has_secure_password

  has_secure_token

  def invalidate_token
    self.update_columns(token: nil)
  end

  has_many :profiles
end

class User < ApplicationRecord
  rolify
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable

  has_one_attached :avatar
  validates :name, presence: true, if: -> { name_changed? }
  validates :phone_number, presence: true, uniqueness: true, if: -> { phone_number_changed? }

  has_many :reservations
  has_many :reservation_members
  has_many :joined_reservations, through: :reservation_members, source: :reservation
  has_many :check_ins

  validates :password, presence: true, length: { minimum: 8 }, format: { 
    with: /\A(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*]).{8,}\z/,
    message: "must include at least one uppercase letter, one lowercase letter, one digit, and one special character (!@#$%^&*)"
  }, if: -> { new_record? || !password.nil? }

end

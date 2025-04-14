class User < ApplicationRecord
  rolify
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable

  has_one_attached :avatar
  validates :name, presence: true, if: -> { name_changed? }
  validates :phone_number, presence: true, uniqueness: true, if: -> { phone_number_changed? }
  # validate :validate_avatar_file_type, if: -> { avatar.attached? }
  # validate :validate_avatar_file_size, if: -> { avatar.attached? }

  has_many :reservations
  has_many :reservation_members
  has_many :joined_reservations, through: :reservation_members, source: :reservation
  has_many :check_ins

  validate :validate_password_complexity, if: :password_required?

  # Add current_password validation
  attr_accessor :current_password

  validate :validate_current_password, if: :password_change_requested?

  private
  

  def validate_password_complexity
    return if password.blank?
  
    unless password.length >= 8 &&
           password =~ /[a-z]/ &&
           password =~ /[A-Z]/ &&
           password =~ /\d/ &&
           password =~ /[!@#$%^&*]/
  
      errors.add(:password, "must be at least 8 characters long and include at least one uppercase letter, one lowercase letter, one digit, and one special character (!@#$%^&*)")
    end
  end  

  def password_required?
    new_record? || password.present? || password_confirmation.present?
  end  

  def password_change_requested?
    password.present? || password_confirmation.present? || current_password.present?
  end

  def validate_current_password
    return if current_password.blank?
    return if valid_password?(current_password)

    errors.add(:current_password, "is incorrect")
  end

  def validate_avatar_file_type
    return unless avatar.attached?
    
    unless avatar.content_type.in?(%w[image/jpeg image/png image/gif image/webp])
      errors.add(:avatar, 'must be a JPEG, PNG, GIF, or WEBP image')
    end
  end

  def validate_avatar_file_size
    return unless avatar.attached?
    return unless avatar.blob&.byte_size
  
    if avatar.blob.byte_size > 5.megabytes
      errors.add(:avatar, 'size must be less than 5MB')
    end
  end  
end

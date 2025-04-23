class Reservation < ApplicationRecord
  extend FriendlyId
  attr_accessor :current_user

  friendly_id :slug, use: :slugged

  after_create :set_custom_slug

  belongs_to :user
  belongs_to :updated_by, class_name: "User", optional: true

  belongs_to :room
  has_many :reservation_members, dependent: :destroy
  has_many :members, through: :reservation_members, source: :user
  has_many :reservation_subscribers, dependent: :destroy
  has_many :subscribers, through: :reservation_subscribers, source: :user
  has_one :check_in, dependent: :destroy

  enum :status, {
    pending: 0,
    checked_in: 1,
    canceled: 2,
    expired: 3,
    completed: 4
  }, default: :pending

  enum :reservation_type, { meeting: 0, conference: 1, workshop: 2, seminar: 3, training: 4, webinar: 5, exclusive: 6 }, default: :meeting

  validates :user_id, presence: true
  validates :start_date, presence: true
  # validates :end_date, presence: true
  validates :start_time, presence: true
  validates :end_time, presence: true
  validates :status, presence: true, inclusion: { in: statuses.keys }
  validates :description, length: { maximum: 500 }, allow_blank: true

  validate :start_time_before_end_time
  validate :start_date_before_end_date
  validate :room_availability

  validate :start_date_is_today_or_future, if: :start_date_changed?
  validate :start_time_is_in_the_future, if: :start_time_changed?
  validate :end_time_is_in_the_future, if: :end_time_changed?

  validate :room_status_is_available

  private

  def start_time_before_end_time
    return unless start_time_changed? || end_time_changed?

    if start_time.present? && end_time.present? && start_time >= end_time
      errors.add(:start_time, "must be before end time")
    end
  end

  def start_date_before_end_date
    return unless start_date_changed? || end_date_changed?

    if start_date.present? && end_date.present? && start_date > end_date
      errors.add(:start_date, "must be before or the same as the end date")
    end
  end

  def room_availability
    return if room.nil? || start_date.nil? || end_date.nil? || start_time.nil? || end_time.nil?
    Rails.logger.info("room_availability: #{room.id} | start_date: #{start_date} | end_date: #{end_date} | start_time: #{start_time} | end_time: #{end_time}")
    return unless start_date_changed? || end_date_changed? || start_time_changed? || end_time_changed?
    Rails.logger.info("room_availability1: #{room.id} | start_date: #{start_date} | end_date: #{end_date} | start_time: #{start_time} | end_time: #{end_time}")

    overlapping_reservations = Reservation.where(room_id: room.id)
                                          .where("status NOT IN (?)", [ Reservation.statuses[:canceled], Reservation.statuses[:completed] ])
                                          .where("(start_date <= ? AND end_date >= ?)", end_date, start_date)
                                          .where("(start_time <= ? AND end_time >= ?)", end_time, start_time)

    Rails.logger.info("overlapping_reservations: #{overlapping_reservations.count}")
    overlapping_reservations = overlapping_reservations.where.not(id: id) if persisted?

    if overlapping_reservations.exists?
      errors.add(:room_id, "is already reserved during the selected time")
    end
  end

  def should_generate_new_friendly_id?
    slug.blank?
  end

  def set_custom_slug
    update_column(:slug, "reservation-#{id}")
  end

  def current_time
    Time.current.in_time_zone("Asia/Bangkok").strftime("%H:%M")
  end

  def current_date
    Time.current.in_time_zone("Asia/Bangkok").to_date
  end

  def start_time_is_in_the_future
    return if current_user&.has_role?(:admin)
    return unless start_time_changed?

    if start_date.present? && !(start_date > current_date)
      if start_time.present? && current_time.present?
        formatted_start_time = start_time.strftime("%H:%M")
        Rails.logger.info("formatted_start_time: #{formatted_start_time} | current_time: #{current_time}")
        if formatted_start_time < current_time
          errors.add(:start_time, "must be in the future")
        end
      else
        errors.add(:start_time, "is invalid or missing")
      end
    end
  end

  def end_time_is_in_the_future
    return if current_user&.has_role?(:admin)
    return unless end_time_changed?

    if start_date.present? && !(end_date > current_date)
      if end_time.present? && current_time.present?
        formatted_end_time = end_time.strftime("%H:%M")
        if formatted_end_time < current_time
          errors.add(:end_time, "must be in the future")
        end
      else
        errors.add(:end_time, "is invalid or missing")
      end
    end
  end

  def start_date_is_today_or_future
    return if start_date.nil?
    return unless start_date_changed?

    Rails.logger.info("start_date: #{start_date} | current_date: #{current_date}")
    if start_date < current_date
      errors.add(:start_date, "must be today or in the future")
    end
  end

  # def end_date_is_today_or_future
  #   return if end_date.nil?
  #   return unless end_date_changed?

  #   if end_date < current_date
  #     errors.add(:end_date, "must be today or in the future")
  #   end
  # end

  def room_status_is_available
    return if room.nil?
    return if room.status == "available"
    errors.add(:room_id, "is not available")
  end
end

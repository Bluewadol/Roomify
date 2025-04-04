class Reservation < ApplicationRecord
  extend FriendlyId
  
  friendly_id :reservation_slug, use: :slugged

  belongs_to :user
  belongs_to :room
  has_many :reservation_members, dependent: :destroy
  has_many :members, through: :reservation_members, source: :user
  has_one :check_in, dependent: :destroy


  enum :status, {
  pending: 0,
  checked_in: 1,
  waiting_check_in: 2,
  canceled: 3,
  expired: 4,
  completed: 5
}, default: :pending


  enum :reservation_type, { training: 0, conference: 1, workshop: 2, seminar: 3, meeting: 4, webinar: 5, private_event: 6 }, default: :meeting

  validates :user_id, presence: true
  validates :room_id, presence: true
  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :start_time, presence: true
  validates :end_time, presence: true
  validates :status, presence: true, inclusion: { in: statuses.keys }
  validates :description, length: { maximum: 500 }, allow_blank: true

  validate :start_time_before_end_time
  validate :start_date_before_end_date
  validate :room_availability

  private

  def start_time_before_end_time
    if start_time.present? && end_time.present? && start_time >= end_time
      errors.add(:start_time, "must be before end time")
    end
  end  

  def start_date_before_end_date
    if start_date.present? && end_date.present? && start_date > end_date
      errors.add(:start_date, "must be before or the same as the end date")
    end
  end

  def room_availability
    return if room.nil? || start_date.nil? || end_date.nil? || start_time.nil? || end_time.nil?

    overlapping_reservations = Reservation.where(room_id: room.id)
                                          .where('start_date BETWEEN ? AND ?', start_date, end_date)
                                          .where('start_time < ? AND end_time > ?', end_time, start_time)

    overlapping_reservations = overlapping_reservations.where.not(id: id) if persisted?

    if overlapping_reservations.exists?
      errors.add(:room_id, "is already reserved during the selected time")
    end
  end

  def reservation_slug
    "reservation-#{id}"
  end
  
end

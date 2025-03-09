class Reservation < ApplicationRecord
  belongs_to :user
  belongs_to :room
  has_many :reservation_members, dependent: :destroy
  has_many :members, through: :reservation_members, source: :user
  has_one :check_in, dependent: :destroy

  enum :status, { 
    pending: 0, 
    checked_in: 1, 
    checked_out: 2, 
    canceled: 3, 
    expired: 4, 
    completed: 5
  }, default: :pending

  # Validations
  validates :user_id, presence: true
  validates :room_id, presence: true
  validates :date, presence: true
  validates :start_time, presence: true
  validates :end_time, presence: true
  validates :status, presence: true, inclusion: { in: statuses.keys }

  validate :start_time_before_end_time
  validate :room_availability

  private

  def start_time_before_end_time
    if start_time.present? && end_time.present? && start_time >= end_time
      errors.add(:start_time, "must be before end time")
    end
  end

  def room_availability
    return if room.nil? || date.nil? || start_time.nil? || end_time.nil?

    overlapping_reservations = Reservation.where(room_id: room.id, date: date)
                                          .where('start_time < ? AND end_time > ?', end_time, start_time)

    overlapping_reservations = overlapping_reservations.where.not(id: id) if persisted?

    if overlapping_reservations.exists?
      errors.add(:room_id, "is already reserved during the selected time")
    end
  end
end

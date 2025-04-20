class CheckIn < ApplicationRecord
  belongs_to :reservation
  belongs_to :user
  attr_accessor :current_user

  validate :user_is_member_of_reservation
  # validate :check_in_time_within_allowed_window

  private

  def user_is_member_of_reservation
    return if current_user.nil? # Skip validation if current_user is nil
    
    if !current_user.has_role?(:admin)
      unless reservation.user_id == user_id || reservation.members.include?(user)
        errors.add(:user_id, "must be either the owner or a member of the reservation")
      end
    end
  end

  # def check_in_time_within_allowed_window
  #   return unless reservation.present? && check_in_time.present?

  #   reservation_datetime = reservation.start_date.to_time.change({ hour: reservation.start_time.hour, min: reservation.start_time.min })
  #   reservation_datetime = reservation_datetime.in_time_zone('Asia/Bangkok')

  #   time_window_start = reservation_datetime - 15.minutes
  #   time_window_end = reservation_datetime + 15.minutes

  #   current_time_in_bkk = check_in_time.in_time_zone('Asia/Bangkok')
  #   current_time_in_bkk = current_time_in_bkk - 7.hours

  #   if current_time_in_bkk < time_window_start || current_time_in_bkk > time_window_end
  #     errors.add(:check_in_time, "must be within 15 minutes before or after the reservation's start time.
  #     Current time: #{current_time_in_bkk}, Start window: #{time_window_start}, End window: #{time_window_end}")
  #   end
  # end
end

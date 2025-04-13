class RoomStatusService
  def self.determine_status(room, reservations_in_range)
    booked = reservations_in_range.where(room_id: room.id).exists?
    
    if room.unavailable?
      :unavailable
    elsif booked
      :booked
    else
      :available
    end
  end
end 
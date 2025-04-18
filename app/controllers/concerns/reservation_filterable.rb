module ReservationFilterable
  extend ActiveSupport::Concern

  def filter_reservations(reservations, options = {})
    exclude_ids = options[:exclude_ids] || []
    Rails.logger.info("filter_reservations exclude_ids: #{exclude_ids}")
    Rails.logger.info("filter_reservations reservations: #{reservations.count}")
    Rails.logger.info("start_date: #{@start_date}")
    Rails.logger.info("end_date: #{@end_date}")
    Rails.logger.info("start_time: #{@start_time}")
    Rails.logger.info("end_time: #{@end_time}")

    # Return empty relation if all parameters are empty
    return reservations.none if @start_date.blank? && @end_date.blank? && @start_time.blank? && @end_time.blank?

    reservations = reservations.where.not(id: exclude_ids) if exclude_ids.present?
    reservations = filter_by_date(reservations)
    reservations = filter_by_time(reservations)

    reservations
  end

  # Filter rooms based on reservations and other criteria
  def filter_rooms(rooms, reservations_in_range, options = {})
    current_reservation_id = options[:current_reservation_id]
    
    # Apply name filter if provided
    if params[:name].present?
      trimmed_name = params[:name].strip.downcase
      rooms = rooms.where("LOWER(name) LIKE ?", "%#{trimmed_name}%")
    end
    
    # Apply capacity filter if provided
    if params[:capacity].present?
      rooms = rooms.where("capacity_max >= ?", params[:capacity])
    end
    
    # Apply amenities filter if provided
    if params[:amenities].present? && params[:amenities].reject(&:blank?).any?
      rooms = rooms.left_joins(:room_amenities)
                   .where(room_amenities: { amenity_name: params[:amenities].reject(&:blank?) })
    end
    
    # Determine room status and filter
    rooms = rooms.map do |room|
      status = determine_room_status(room, reservations_in_range)
      room.assign_attributes(status: status)
      room
    end
    
    # Filter by status if provided
    if params[:room_status].present? && params[:room_status].reject(&:blank?).any?
      rooms = rooms.select { |room| params[:room_status].reject(&:blank?).include?(room.status.to_s) }
    end
    
    rooms
  end

  # Sort rooms by status priority
  def sort_rooms_by_status(rooms)
    rooms.sort_by do |room|
      case room.status
      when 'available' then 0
      when 'booked' then 1
      when 'unavailable' then 2
      end
    end
  end

  # Determine room status based on reservations
  def determine_room_status(room, reservations_in_range)
    booked = reservations_in_range.where(room_id: room.id).exists?
    
    if room.unavailable?
      :unavailable
    elsif booked
      :booked
    else
      :available
    end
  end
  
  def next_available_date(next_reservation, start_date, start_time, end_time)
    return nil unless next_reservation.present?
    
    today = Date.current
    
    if today >= next_reservation.start_date && today <= next_reservation.end_date
      if start_time < next_reservation.start_time
        today
      else
        today + 1.day
      end
    elsif today < next_reservation.start_date
      next_reservation.start_date
    else
      today
    end
  end

  private

  def filter_by_date(reservations)
    if @start_date && @end_date
      if @start_date == @end_date
        reservations.where("start_date <= ? AND end_date >= ?", @start_date, @start_date)
      else
        reservations.where(
          "(start_date BETWEEN ? AND ?) OR (end_date BETWEEN ? AND ?) OR (start_date <= ? AND end_date >= ?)",
          @start_date, @end_date, @start_date, @end_date, @start_date, @end_date
        )
      end
    elsif @start_date
      reservations.where("end_date >= ?", @start_date)
    elsif @end_date
      reservations.where("start_date <= ?", @end_date)
    else
      reservations
    end
  end

  def filter_by_time(reservations)
    if @start_time && @end_time
      if @start_time == @end_time
        reservations.where(
          "(start_time <= ? AND end_time >= ?)",
          @start_time, @end_time
        )
      else
        reservations.where(
          "(start_time >= ? AND start_time <= ? AND end_time >= ?) OR (start_time <= ? AND end_time >= ?) OR (start_time >= ? AND end_time <= ?)",
          @start_time, @end_time, @end_time, @start_time, @start_time, @start_time, @end_time
        )
      end
    elsif @start_time
      reservations.where("start_time >= ?", @start_time)
    elsif @end_time
      reservations.where("end_time <= ?", @end_time)
    else
      Rails.logger.info("filter_by_time else")
      reservations
    end
  end
  
  def parse_time_in_zone(date, time_str)
    return nil if date.blank? || time_str.blank?
    Rails.logger.info("parse_time_in_zone date: #{date} | time_str: #{time_str}")
    Time.zone.parse("#{date} #{time_str}")
  end
end 
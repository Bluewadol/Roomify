module ReservationHelper
  # Determine the next available date based on the next reservation
  def next_available_date(next_reservation, start_date, end_date, start_time, end_time)
    return nil unless next_reservation.present?
    
    # Convert string dates to Date objects if needed
    start_date = start_date.is_a?(String) ? Date.parse(start_date) : start_date
    end_date = end_date.is_a?(String) ? Date.parse(end_date) : end_date
    next_start_date = next_reservation.start_date.is_a?(String) ? Date.parse(next_reservation.start_date) : next_reservation.start_date
    next_end_date = next_reservation.end_date.is_a?(String) ? Date.parse(next_reservation.end_date) : next_reservation.end_date
    
    # Extract time part only (hours, minutes, seconds)
    start_time = extract_time_only(start_time)
    end_time = extract_time_only(end_time)
    next_start_time = extract_time_only(next_reservation.start_time)
    next_end_time = extract_time_only(next_reservation.end_time)

    Rails.logger.info("start_date: #{start_date}")
    Rails.logger.info("end_date: #{end_date}")
    Rails.logger.info("next_start_date: #{next_start_date}")
    Rails.logger.info("next_end_date: #{next_end_date}")
    Rails.logger.info("start_time: #{start_time}")
    Rails.logger.info("end_time: #{end_time}")
    Rails.logger.info("next_start_time: #{next_start_time}")
    Rails.logger.info("next_end_time: #{next_end_time}")
    
    # If start_date is within the next reservation date range
    if start_date <= next_start_date && end_date <= next_start_date
        next_start_date
    elsif (start_date < next_start_date && end_date >= next_start_date && end_date <= next_end_date) || (start_date >= next_start_date && start_date <= next_end_date && end_date <= next_end_date) || (start_date >= next_start_date && start_date <= next_end_date && end_date > next_end_date)
        if !start_time.nil?
            if start_time < next_start_time
                start_date
            else
                start_date + 1.day
            end
        else
            start_date
        end
    end
  end
  
  # Extract only the time part (hours, minutes, seconds) from a datetime
  def extract_time_only(time_value)
    return nil if time_value.nil?
    
    if time_value.is_a?(String)
      # Try to parse as Time
      begin
        time = Time.parse(time_value)
        return time.strftime("%H:%M:%S")
      rescue ArgumentError
        # If parsing fails, return the original string
        return time_value
      end
    elsif time_value.is_a?(Time) || time_value.is_a?(DateTime)
      # If it's already a Time or DateTime, extract just the time part
      return time_value.strftime("%H:%M:%S")
    else
      # For other types, return as is
      return time_value
    end
  end
end 
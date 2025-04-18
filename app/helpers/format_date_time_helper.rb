module FormatDateTimeHelper
    def format_datetime(date_or_time, time_only: false)
        return "" if date_or_time.nil?

        if date_or_time.is_a?(Date)
            date_or_time.strftime("%d %b %Y")
        elsif date_or_time.is_a?(Time) || date_or_time.is_a?(DateTime)
            if time_only
            date_or_time.strftime("%H:%M")
            else
            date_or_time.strftime("%d %b %Y %H:%M")
            end
        else
            date_or_time.to_s
        end
    end

    def time_elapsed(from_time)
        elapsed_minutes = ((Time.current - from_time) / 60).to_i
        elapsed_hours = (elapsed_minutes / 60).to_i
        elapsed_days = (elapsed_hours / 24).to_i
        elapsed_months = (elapsed_days / 30).to_i
        elapsed_years = (elapsed_days / 365).to_i

        if elapsed_years > 0
            "#{elapsed_years} year#{'s' if elapsed_years > 1}"
        elsif elapsed_months > 0
            "#{elapsed_months} month#{'s' if elapsed_months > 1}"
        elsif elapsed_days > 0
            "#{elapsed_days} day#{'s' if elapsed_days > 1}"
        elsif elapsed_hours > 0
            "#{elapsed_hours} hour#{'s' if elapsed_hours > 1}"
        else
            "#{elapsed_minutes} min"
        end
    end
end

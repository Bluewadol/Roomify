class User::RoomsController < ApplicationController
  include ReservationFilterable
  
  before_action :set_room, only: [:show]
  before_action :set_filter_params, only: [:index]
  before_action :set_filter_room_details_params, only: [:show]

  def index
    @rooms = Room.includes(:reservations, :room_amenities)
    @maximum_capacity = @rooms&.maximum(:capacity_max) || 100
    @amenities = RoomAmenity.distinct.pluck(:amenity_name)
    
    # Filter reservations
    @reservations_in_range = filter_reservations(Reservation.all)
    
    # Filter and sort rooms
    @rooms = filter_rooms(@rooms, @reservations_in_range)
    @rooms = sort_rooms_by_status(@rooms)
    
    # Add pagination with custom per_page value
    per_page = params[:room_per_page].present? ? params[:room_per_page].to_i : 5
    @rooms = Kaminari.paginate_array(@rooms).page(params[:room_page]).per(per_page)
    
    @room_status = Room.statuses.keys 
  end

  def show
    @capacity_range = @room.capacity_min == @room.capacity_max ? @room.capacity_max : "#{@room.capacity_min} - #{@room.capacity_max}"
    
    # Filter reservations for this room
    @reservations_in_range = filter_reservations(Reservation.where(room_id: @room.id))
    @current_reservation = @reservations_in_range.where.not(status: [:canceled, :expired, :completed]).first

    # Determine room status
    status = determine_room_status(@room, @reservations_in_range)
    @room.assign_attributes(status: status)
    @room_status = Room.statuses.keys
  end

  private

  def set_room
    @room = Room.friendly
                .includes(:room_amenities)
                .find(params[:slug])
                
    # Load reservations separately with proper sorting
    @room.reservations = Reservation.where(room_id: @room.id).order(updated_at: :desc)
  rescue ActiveRecord::RecordNotFound
    redirect_to rooms_path, alert: "Room not found."
  end   

  def set_filter_params
    Time.zone = 'Bangkok'
    @start_date = params[:start_date].presence || Time.zone.today.to_s
    @end_date   = params[:end_date].presence   || Time.zone.today.to_s
    @start_time = params[:start_time].presence 
    @end_time   = params[:end_time].presence
    @selected_amenities = params[:amenities]&.reject(&:blank?) || []
    @selected_status = params[:room_status]&.reject(&:blank?) || []
  end

  def set_filter_room_details_params
    Time.zone = 'Bangkok'
    @start_date = params[:start_date].presence || Time.zone.today.to_s
    @end_date   = params[:end_date].presence   || Time.zone.today.to_s
    @start_time = params[:start_time].presence || Time.zone.now.strftime("%H:%M")
    @end_time   = params[:end_time].presence   || Time.zone.now.strftime("%H:%M")
    @selected_amenities = params[:amenities]&.reject(&:blank?) || []
    @selected_status = params[:room_status]&.reject(&:blank?) || []
    # Only call set_reference_datetime if @room exists
    @room&.set_reference_datetime(@start_date, @start_time, @end_date, @end_time)
  end
  
  def apply_filters(rooms)
    rooms = filter_by_name(rooms) if params[:name].present?
    rooms = filter_by_capacity(rooms) if @capacity.present?
    rooms = filter_by_amenities(rooms) if @selected_amenities.present?
    
    rooms.map do |room|
      status = determine_room_status(room, @reservations_in_range)
      room.assign_attributes(status: status)
      room
    end
  end
  
  def filter_by_name(rooms)
    trimmed_name = params[:name].strip.downcase
    rooms.where("LOWER(name) LIKE ?", "%#{trimmed_name}%")
  end
  
  def filter_by_capacity(rooms)
    rooms.where("capacity_max >= ?", @capacity)
  end
  
  def filter_by_amenities(rooms)
    rooms.left_joins(:room_amenities)
         .where(room_amenities: { amenity_name: @selected_amenities })
  end
  
  def apply_status_filters(rooms)
    if @selected_status.present?
      rooms = rooms.select { |room| @selected_status.include?(room.status.to_s) }
    end
  
    if @selected_status == "booked"
      rooms = rooms.select do |room|
        booked = @reservations_in_range.where(room_id: room.id).exists?
      end
    end
    
    rooms
  end
  
  def sort_rooms_by_status(rooms)
    rooms.sort_by do |room|
      case room.status
      when 'available' then 0
      when 'booked' then 1
      when 'unavailable' then 2
      end
    end
  end
end

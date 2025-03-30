class User::RoomsController < ApplicationController
  before_action :set_room, only: [:show]

  def index
    @rooms = Room.includes(:reservations, :room_amenities)

    @start_date = params[:start_date].presence
    @end_date = params[:end_date].presence
    @start_time = params[:start_time].presence
    @end_time = params[:end_time].presence
    @capacity = params[:capacity].presence
    @selected_amenities = params[:amenities]&.reject(&:blank?) || []
    @selected_status = params[:room_status]&.reject(&:blank?) || []

    @reservations_in_range = Reservation.all

    if @start_date && @end_date
      @reservations_in_range = if @start_date == @end_date
        @reservations_in_range.where(start_date: @start_date)
      else
        @reservations_in_range.where(start_date: @start_date..@end_date)
      end
    elsif @start_date
      @reservations_in_range = @reservations_in_range.where("start_date >= ?", @start_date)
    elsif @end_date
      @reservations_in_range = @reservations_in_range.where("end_date <= ?", @end_date)
    end
    
    if @start_time && @end_time
      if @start_time == @end_time
        @reservations_in_range = @reservations_in_range.where("start_time <= ? AND end_time >= ?", @start_time, @start_time)
      else
        @reservations_in_range = @reservations_in_range.where("start_time < ? AND end_time > ?", @end_time, @start_time)
      end
    elsif @start_time
      @reservations_in_range = @reservations_in_range.where("start_time >= ?", @start_time)
    elsif @end_time
      @reservations_in_range = @reservations_in_range.where("end_time <= ?", @end_time)
    end    

    if params[:name].present?
      trimmed_name = params[:name].strip.downcase
      @rooms = @rooms.where("LOWER(name) LIKE ?", "%#{trimmed_name}%")
    end

    if @capacity.present?
      @rooms = @rooms.where("capacity_max >= ?", @capacity)
    end

    if @selected_amenities.present?
      @rooms = @rooms.left_joins(:room_amenities)
                     .where(room_amenities: { amenity_name: @selected_amenities })
    end    
    
    def determine_room_status(room)
      booked = @reservations_in_range.where(room_id: room.id).exists?
      if room.unavailable?
        :unavailable
      elsif booked
        :booked
      else
        :available
      end
    end
    
    @rooms = @rooms.map do |room|
      status = determine_room_status(room)
      room.assign_attributes(status: status)
      room
    end

    if @selected_status.present?
      @rooms = @rooms.select { |room| @selected_status.include?(room.status.to_s) }
    end
  
    if @selected_status == "booked"
      @rooms = @rooms.select do |room|
        booked = @reservations_in_range.where(room_id: room.id).exists?
      end
    end
    
    @maximum_capacity = @rooms&.maximum(:capacity_max) || 100
    @amenities = RoomAmenity.distinct.pluck(:amenity_name)
    @room_status = Room.statuses.keys 
  end

  def show; end

  private

  def set_room
    @room = Room.includes(:room_amenities).find(params[:id])
  end
end

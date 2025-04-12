class User::ReservationsController < ApplicationController
  before_action :set_reservation, only: %i[show edit update destroy]

  def index
    # Get reservations created by the current user or where the current user is a member
    @reservations = Reservation.includes(:room)
      .where('user_id = ? OR id IN (SELECT reservation_id FROM reservation_members WHERE user_id = ?)', 
             current_user.id, current_user.id)
    
    @upcoming_reservations = @reservations
      .where(status: [:pending, :waiting_check_in])
      .order(start_date: :desc, start_time: :desc)
    @past_reservations = @reservations
      .where.not(status: [:pending, :waiting_check_in])
      .order(start_date: :desc, start_time: :desc)
  end  

  def show; end

  def new
    set_rooms()
    @reservation = Reservation.new
    @room_select = Room.find_by(id: params[:room_id])
    @reservation.room_id = @room_select.id if @room_select
  end

  def create
    @reservation = current_user.reservations.build(reservation_params)
    @reservation.updated_by = current_user
    set_rooms()
  
    if @reservation.save
      @reservation.members = User.where(id: params[:reservation][:member_ids].reject(&:blank?)) if params[:reservation][:member_ids]
      redirect_to @reservation, notice: "Reservation was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end  

  def edit
    # Only the owner can edit a reservation
    if @reservation.user_id == current_user.id
      set_rooms(@reservation.id)
      @room_select = Room.find_by(id: params[:room_id])
      @reservation.room_id = @room_select.id if @room_select
    else
      redirect_to reservation_path(@reservation), alert: "You don't have permission to edit this reservation."
    end
  end
  
  def update
    # Only the owner can update a reservation
    if @reservation.user_id == current_user.id || @reservation.members.include?(current_user)
      set_rooms(@reservation.id)
      @reservation.updated_by = current_user
      if @reservation.update(reservation_params)
        @reservation.members = User.where(id: params[:reservation][:member_ids]) if params[:reservation][:member_ids]
        redirect_to @reservation, notice: "Reservation was successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    else
      redirect_to reservation_path(@reservation), alert: "You don't have permission to update this reservation."
    end
  end

  def destroy
    # Only the owner can delete a reservation
    if @reservation.user_id == current_user.id
      @reservation.destroy
      redirect_to reservations_path, notice: "Reservation was successfully deleted."
    else
      redirect_to reservation_path(@reservation), alert: "You don't have permission to delete this reservation."
    end
  end

  private

  def set_reservation
    @reservation = Reservation.friendly.find(params[:slug])
    
    # Check if the current user is the owner or a member of the reservation
    unless @reservation.user_id == current_user.id || @reservation.members.include?(current_user)
      redirect_to reservations_path, alert: "You don't have permission to access this reservation."
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to reservations_path, alert: "Reservation not found." 
  end

  def reservation_params
    params.require(:reservation).permit(:room_id, :start_date, :end_date, :start_time, :end_time, :description, :reservation_type, member_ids: [])
  end  

  def set_rooms(current_reservation_id = nil)
    if params[:room_id].present?
      @room = Room.find_by(id: params[:room_id])
    elsif current_reservation_id.present?
      @room = @reservation.room
    end

    @rooms = Room.includes(:reservations, :room_amenities)
  
    @start_date = params[:start_date].presence
    @end_date = params[:end_date].presence
    @start_time = params[:start_time].presence
    @end_time = params[:end_time].presence

    Rails.logger.debug("Start Date: #{@start_date}, End Date: #{@end_date}, Start Time: #{@start_time}, End Time: #{@end_time}")
  
    @reservations_in_range = Reservation.all
    @reservations_in_range = @reservations_in_range.where.not(id: current_reservation_id) if current_reservation_id.present?
  
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
        @reservations_in_range = @reservations_in_range.where(
          "(start_time <= ? AND end_time >= ?)",
          @start_time, @end_time
        )
      else
        @reservations_in_range = @reservations_in_range.where(
          "(start_time >= ? AND start_time <= ? AND end_time >= ?) OR (start_time <= ? AND end_time >= ?)",
          @start_time, @end_time, @end_time, @start_time, @start_time
        )
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
      room.define_singleton_method(:status) { status }
      room
    end.select do |room|
      if current_reservation_id && room.id == Reservation.find(current_reservation_id).room_id
        true
      else
        room.status == :available
      end
    end
  end  

end
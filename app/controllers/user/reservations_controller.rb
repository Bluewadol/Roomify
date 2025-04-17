class User::ReservationsController < ApplicationController
  include ReservationFilterable
  
  before_action :set_reservation, only: %i[show edit update destroy]
  before_action :set_filter_params, only: [:new, :edit]

  def index
    # Get reservations created by the current user or where the current user is a member
    @reservations = Reservation.includes(:room)
      .where('user_id = ? OR id IN (SELECT reservation_id FROM reservation_members WHERE user_id = ?)', 
             current_user.id, current_user.id)
    
    # Add pagination for upcoming reservations
    upcoming_per_page = params[:upcoming_per_page].present? ? params[:upcoming_per_page].to_i : 5
    @upcoming_reservations = @reservations
      .where(status: [:pending, :in_use])
      .order(start_date: :desc, start_time: :desc)
    @upcoming_reservations = Kaminari.paginate_array(@upcoming_reservations).page(params[:upcoming_page]).per(upcoming_per_page)
    
    # Add pagination for past reservations
    past_per_page = params[:past_per_page].present? ? params[:past_per_page].to_i : 10
    @past_reservations = @reservations
      .where.not(status: [:pending, :in_use])
      .order(start_date: :desc, start_time: :desc)
    @past_reservations = Kaminari.paginate_array(@past_reservations).page(params[:past_page]).per(past_per_page)
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
    # Check if the user has permission to edit this reservation
    unless @reservation.user_id == current_user.id || @reservation.members.include?(current_user)
      redirect_to reservation_path(@reservation), alert: "You don't have permission to edit this reservation."
      return
    end
    
    # Check if the reservation status allows editing
    unless @reservation.pending?
      redirect_to reservation_path(@reservation), alert: "This reservation cannot be edited."
      return
    end
    
    set_rooms(@reservation.id)
    @room_select = Room.find_by(id: params[:room_id])
    @reservation.room_id = @room_select.id if @room_select
  end
  
  def update
    # Check if the user has permission to update this reservation
    unless @reservation.user_id == current_user.id || @reservation.members.include?(current_user)
      redirect_to reservation_path(@reservation), alert: "You don't have permission to update this reservation."
      return
    end

    if params[:reservation][:status] == "completed" && @reservation.checked_in?
      completed_reservation()
      return
    end
    
    # Check if the reservation status allows updating
    unless @reservation.pending?
      redirect_to reservation_path(@reservation), alert: "This reservation cannot be updated because it's no longer in pending or waiting check-in status."
      return
    end
    
    set_rooms(@reservation.id)
    @reservation.updated_by = current_user
    if @reservation.update(reservation_params)
      @reservation.members = User.where(id: params[:reservation][:member_ids]) if params[:reservation][:member_ids]
      redirect_to @reservation, notice: "Reservation was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
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
    
  rescue ActiveRecord::RecordNotFound
    redirect_to reservations_path, alert: "Reservation not found." 
  end

  def reservation_params
    params.require(:reservation).permit(:room_id, :start_date, :end_date, :status, :start_time, :end_time, :description, :reservation_type, member_ids: [])
  end  

  def set_filter_params
    Time.zone = 'Bangkok'
    @start_date = params[:start_date].presence || Time.zone.today.to_s
    @end_date   = params[:end_date].presence   || Time.zone.today.to_s
    @start_time = params[:start_time].presence || Time.zone.now.strftime("%H:%M")
    @end_time   = params[:end_time].presence   || Time.zone.now.strftime("%H:%M")
  end

  def set_rooms(current_reservation_id = nil)
    if params[:room_id].present?
      @room = Room.find_by(id: params[:room_id])
    elsif current_reservation_id.present?
      @room = @reservation.room
    end

    @rooms = Room.includes(:reservations, :room_amenities)
    
    # Filter reservations
    @reservations_in_range = filter_reservations(Reservation.all, exclude_ids: current_reservation_id ? [current_reservation_id] : [])
    
    # Filter and sort rooms
    @rooms = filter_rooms(@rooms, @reservations_in_range, current_reservation_id: current_reservation_id)
    @rooms = sort_rooms_by_status(@rooms)
    
    # Add pagination with custom per_page value
    per_page = params[:room_per_page].present? ? params[:room_per_page].to_i : 5
    @rooms = Kaminari.paginate_array(@rooms).page(params[:room_page]).per(per_page)
  end

  def completed_reservation
    @reservation = Reservation.friendly.find(params[:slug])
    @reservation.update(status: :completed)
    redirect_to @reservation, notice: "Reservation was successfully completed."
  end
end
class User::ReservationsController < ApplicationController
  include ReservationFilterable

  before_action :set_reservation, only: %i[show edit update destroy subscribe unsubscribe]
  before_action :set_filter_params, only: [ :new, :edit ]
  before_action :set_current_user, only: [ :new, :edit ]

  def index
    # Get reservations created by the current user or where the current user is a member
    @reservations = Reservation.includes(:room)
      .where("user_id = ? OR id IN (SELECT reservation_id FROM reservation_members WHERE user_id = ?)",
             current_user.id, current_user.id)

    # Add pagination for upcoming reservations
    upcoming_per_page = params[:upcoming_per_page].present? ? params[:upcoming_per_page].to_i : 5
    @upcoming_reservations = @reservations
      .where(status: [ :pending, :checked_in ])
      .order(start_date: :desc, start_time: :desc)
    @upcoming_reservations = Kaminari.paginate_array(@upcoming_reservations).page(params[:upcoming_page]).per(upcoming_per_page)

    # Add pagination for past reservations
    past_per_page = params[:past_per_page].present? ? params[:past_per_page].to_i : 10
    @past_reservations = @reservations
      .where.not(status: [ :pending, :checked_in ])
      .order(start_date: :desc, start_time: :desc)
    @past_reservations = Kaminari.paginate_array(@past_reservations).page(params[:past_page]).per(past_per_page)

    @all_reservations = Reservation.includes(:room).order(start_date: :desc, start_time: :desc)
    @all_reservations = Kaminari.paginate_array(@all_reservations).page(params[:all_page]).per(params[:all_per_page])
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

  def subscribe
    if @reservation.subscribers.include?(current_user)
      redirect_to reservation_path(@reservation), alert: "You are already subscribed to this reservation"
      return
    end

    order = @reservation.subscribers.count + 1
    ReservationSubscriber.create!(
      reservation: @reservation,
      user: current_user,
      order: order
    )

    redirect_to reservation_path(@reservation), notice: "Successfully subscribed to the reservation"
  end

  def unsubscribe
    subscriber = @reservation.reservation_subscribers.find_by(user_id: params[:user_id])
    
    # Check if the current user is either the reservation owner or the subscriber themselves
    unless @reservation.user_id == current_user.id || params[:user_id].to_i == current_user.id
      flash[:alert] = "You don't have permission to remove this subscriber"
      redirect_to reservation_path(@reservation)
      return
    end
    
    if subscriber
      subscriber.destroy
      # Reorder remaining subscribers
      @reservation.reservation_subscribers.order(:order).each_with_index do |sub, index|
        sub.update(order: index + 1)
      end
      flash[:notice] = "Successfully removed subscriber"
    else
      flash[:alert] = "Subscriber not found"
    end
    
    redirect_to reservation_path(@reservation)
  end

  private

  def set_reservation
    @reservation = Reservation.friendly.find(params[:slug])

  rescue ActiveRecord::RecordNotFound
    redirect_to reservations_path, alert: "Reservation not found."
  end

  def reservation_params
    if params[:reservation][:start_date].present?
      params[:reservation][:end_date] = params[:reservation][:start_date]
    end
    params.require(:reservation).permit(:room_id, :start_date, :end_date, :status, :start_time, :end_time, :description, :reservation_type, member_ids: [])
  end

  def set_filter_params
    Time.zone = "Bangkok"
    @start_date = params[:start_date].presence || Time.zone.today.to_s
    # @end_date   = params[:end_date].presence   || Time.zone.today.to_s
    @end_date   = params[:end_date].presence   || Time.zone.today.to_s
    @start_time = parse_time_in_zone(@start_date, params[:start_time]) || parse_time_in_zone(Time.zone.today, Time.zone.now.strftime("%H:%M"))
    @end_time   = parse_time_in_zone(@end_date, params[:end_time]) || parse_time_in_zone(Time.zone.today, Time.zone.now.strftime("%H:%M"))
    # Only call set_reference_datetime if @room exists
    @room&.set_reference_datetime(@start_date, @start_time, @end_date, @end_time)
  end

  def set_rooms(current_reservation_id = nil)
    if params[:room_id].present?
      @room = Room.find_by(id: params[:room_id])
    elsif current_reservation_id.present?
      @room = @reservation.room
    end

    @rooms = Room.includes(:reservations, :room_amenities)

    # Filter reservations
    @reservations_in_range = filter_reservations(Reservation.all, exclude_ids: current_reservation_id ? [ current_reservation_id ] : [])

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

  def set_current_user
    @current_user = current_user
  end
end

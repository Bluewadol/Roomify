class User::ReservationsController < ApplicationController
  before_action :set_reservation, only: %i[show edit update destroy]

  def index
    @reservations = current_user.reservations.includes(:room)
  end

  def show; end

  def new
    @room = Room.find_by(id: params[:room_id]) if params[:room_id].present?
    @reservation = Reservation.new
  end

  def create
    @reservation = current_user.reservations.build(reservation_params)
  
    if @reservation.save
      @reservation.members = User.where(id: params[:reservation][:member_ids].reject(&:blank?)) if params[:reservation][:member_ids]
      redirect_to @reservation, notice: "Reservation was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end  

  def edit; end

  def update
    if @reservation.update(reservation_params)
      @reservation.members = User.where(id: params[:reservation][:member_ids]) if params[:reservation][:member_ids]
      redirect_to @reservation, notice: "Reservation was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @reservation.destroy
    redirect_to reservations_path, notice: "Reservation was successfully deleted."
  end

  private

  def set_reservation
    @reservation = current_user.reservations.find(params[:id])
  end

  def reservation_params
    params.require(:reservation).permit(:room_id, :start_date, :end_date, :start_time, :end_time, :description, member_ids: [])
  end  
end
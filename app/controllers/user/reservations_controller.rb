class User::ReservationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_reservation, only: %i[show edit update destroy]

  def index
    @reservations = current_user.reservations.includes(:room)
  end

  def show; end

  def new
    @reservation = Reservation.new
  end

  def create
    @reservation = current_user.reservations.build(reservation_params)

    if @reservation.save
      if params[:reservation][:user_ids].present?
        params[:reservation][:user_ids].each do |user_id|
          @reservation.members << User.find(user_id) unless user_id.blank?
        end
      end
      redirect_to @reservation, notice: "Reservation was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @reservation.update(reservation_params)
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
    params.require(:reservation).permit(:room_id, :date, :start_time, :end_time)
  end
end
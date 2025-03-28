class User::RoomsController < ApplicationController
  before_action :set_room, only: [:show]

  def index
    @rooms = Room.includes(:reservations)
    

    @start_date = params[:start_date].presence
    @end_date = params[:end_date].presence
    @start_time = params[:start_time].presence
    @end_time = params[:end_time].presence

    @reservations_in_range = Reservation.all

    if @start_date && @end_date
      @reservations_in_range = @reservations_in_range.where("date BETWEEN ? AND ?", @start_date, @end_date)
    elsif @start_date
      @reservations_in_range = @reservations_in_range.where(date: @start_date)
    elsif @end_date
      @reservations_in_range = @reservations_in_range.where(date: @end_date)
    end

    if @start_time && @end_time
      @reservations_in_range = @reservations_in_range.where("start_time < ? AND end_time > ?", @end_time, @start_time)
    elsif @start_time
      @reservations_in_range = @reservations_in_range.where("start_time <= ?", @start_time)
    elsif @end_time
      @reservations_in_range = @reservations_in_range.where("end_time >= ?", @end_time)
    end

    if params[:name].present?
      trimmed_name = params[:name].strip.downcase
      @rooms = @rooms.where("LOWER(name) LIKE ?", "%#{trimmed_name}%")
    end
  end

  def show; end

  private

  def set_room
    @room = Room.includes(:room_amenities).find(params[:id])
  end
end

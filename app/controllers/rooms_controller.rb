class RoomsController < ApplicationController
  before_action :set_room, only: [:show]

  def index
    @rooms = Room.includes(:room_amenities).all
  end

  def show; end

  private

  def set_room
    @room = Room.includes(:room_amenities).find(params[:id])
  end
end

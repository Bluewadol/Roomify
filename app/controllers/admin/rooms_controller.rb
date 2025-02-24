class Admin::RoomsController < ApplicationController
    before_action :set_room, only: [ :show, :edit, :update, :destroy ]

    def index
        @rooms = Room.all
    end

    def show; end

    def new
        @room = Room.new
    end

    def create
        @room = Room.new(room_params)
        if @room.save
            redirect_to admin_rooms_path, notice: "Room created successfully."
        else
            render :new, status: :unprocessable_entity
        end
    end

    def edit; end

    def update
        if @room.update(room_params)
            redirect_to admin_rooms_path, notice: "Room updated successfully."
        else
            render :edit, status: :unprocessable_entity
        end
    end

    def destroy
        @room.qr_code.purge
        @room.destroy
        redirect_to admin_rooms_path, notice: "Room deleted successfully."
    end

    private

    def set_room
        @room = Room.find(params[:id])
    end

    def room_params
        params.require(:room).permit(:name, :capacity_min, :capacity_max, :status, :qr_code)
    end
end

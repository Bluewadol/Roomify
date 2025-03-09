class Admin::RoomAmenitiesController < Admin::BaseController
    before_action :set_room
    before_action :set_amenity, only: [ :show, :edit, :update, :destroy ]

    def index
        @amenities = @room.room_amenities
    end

    def show; end

    def new
        @amenity = @room.room_amenities.new
    end

    def create
        @amenity = @room.room_amenities.new(amenity_params)
        if @amenity.save
            redirect_to admin_room_room_amenities_path(@room), notice: "Amenity added successfully."
        else
            render :new, status: :unprocessable_entity
        end
    end

    def edit; end

    def update
        if @amenity.update(amenity_params)
            redirect_to admin_room_room_amenities_path(@room), notice: "Amenity updated successfully."
        else
            render :edit, status: :unprocessable_entity
        end
    end

    def destroy
        @amenity.destroy
        redirect_to admin_room_room_amenities_path(@room), notice: "Amenity deleted successfully."
    end

    private

    def set_room
        @room = Room.find(params[:room_id])
    end

    def set_amenity
        @amenity = @room.room_amenities.find(params[:id])
    end

    def amenity_params
        params.require(:room_amenity).permit(:amenity_name, :quantity)
    end
end

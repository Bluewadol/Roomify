class Admin::ReservationsController < Admin::BaseController
    before_action :set_room, only: [:index, :edit, :update, :show, :destroy]
    before_action :set_reservation, only: [:edit, :update, :show, :destroy]

    def index
        @reservations = @room.reservations
    end

    def show
    end

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

    def edit
    end

    # def update
    #     if @reservation.update(reservation_params)
    #         if params[:reservation][:user_ids].present?
    #             params[:reservation][:user_ids].each do |user_id|
    #                 user = User.find(user_id)
    #                 @reservation.members << user unless @reservation.members.include?(user)
    #             end
    #         end
    #         redirect_to admin_room_reservation_path(@room, @reservation), notice: "Reservation was successfully updated."
    #     else
    #         render :edit, status: :unprocessable_entity
    #     end
    # end

    def update
        if @reservation.update(reservation_params)
            if params[:reservation][:user_ids].present?
                @reservation.members.each do |member|
                    unless params[:reservation][:user_ids].include?(member.id.to_s)
                    @reservation.members.delete(member)
                    end
                end

                params[:reservation][:user_ids].each do |user_id|
                    user = User.find(user_id)
                    unless @reservation.members.include?(user)
                    @reservation.members << user
                    end
                end
            end

            if @reservation.save
                redirect_to admin_room_reservation_path(@room, @reservation), notice: "Reservation was successfully updated."
            else
                render :edit, status: :unprocessable_entity
            end
        else
            render :edit, status: :unprocessable_entity
        end
    end

    def destroy
        @reservation.destroy
        redirect_to admin_rooms_path, notice: "Reservation was successfully deleted."
    end

    private

    def set_room
        @room = Room.find(params[:room_id])
    end

    def set_reservation
        @reservation = @room.reservations.find(params[:id])
    end

    def reservation_params
        params.require(:reservation).permit(:room_id, :date, :start_time, :end_time)
    end
end
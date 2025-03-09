class Room::CheckInsController < ApplicationController
    before_action :set_reservation
    before_action :set_check_in, only: [:show, :edit, :update, :destroy]

    def new
      @check_in = CheckIn.new(reservation_id: @reservation.id)
    end
  
    def create
        @check_in = @reservation.build_check_in(check_in_params)
        
        if @check_in.save
            @reservation.update(status: :checked_in)
            redirect_to reservation_path(@reservation), notice: 'Check-in successful.'
        else
            render :new, status: :unprocessable_entity
        end
    end

    def show
    end

    def edit
    end

    def update
      if @check_in.update(check_in_params)
        redirect_to room_check_in_path(@check_in), notice: "Check-in was successfully updated."
      else
        render :edit
      end
    end

    def destroy
      @check_in.destroy
      redirect_to room_check_ins_path, notice: "Check-in was successfully destroyed."
    end

    private

    def set_reservation
      @reservation = Reservation.find(params[:reservation_id])
    end

    def set_check_in
      @check_in = @reservation.check_in
    end

    def check_in_params
      params.require(:check_in).permit(:reservation_id, :user_id, :check_in_time)
    end
end

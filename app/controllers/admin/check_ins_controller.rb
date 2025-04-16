class User::CheckInsController < ApplicationController
    before_action :set_reservation, only: [:new, :create]

    def new
      @check_in = CheckIn.new(reservation_id: @reservation.id)
    end
  
    def create
      @check_in = @reservation.build_check_in(check_in_params)
      if @check_in.save
        @reservation.status = :in_use
        @reservation.updated_by = current_user
        @reservation.save
        redirect_to reservation_path(@reservation), notice: 'Check-in successful.'
      else
        render :new, status: :unprocessable_entity
      end
    end    

    def show
    end

    private

    def set_reservation 
      @reservation = Reservation.friendly.find(params[:reservation_slug])

    rescue ActiveRecord::RecordNotFound => e
      redirect_to request.referer, alert: "Reservation not found." 
    end

    def check_in_params
      params.require(:check_in).permit(:reservation_id, :user_id, :check_in_time)
    end
end

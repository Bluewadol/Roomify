class User::CheckInsController < ApplicationController
    before_action :set_reservation, only: [:new, :create]
    before_action :validate_reservation_status, only: [:new, :create]

    def new
      @check_in = CheckIn.new(reservation_id: @reservation.id)
    end
  
    def create
      @check_in = @reservation.build_check_in(check_in_params)
      if @check_in.save
        @reservation.status = :checked_in
        @reservation.updated_by = current_user
        if @reservation.save
          redirect_to reservation_path(@reservation), notice: 'Check-in successful.'
        else
          @check_in.destroy
          render :new, status: :unprocessable_entity, alert: 'Failed to update reservation status.'
        end
      else
        render :new, status: :unprocessable_entity, alert: @check_in.errors.full_messages.join(', ')
      end
    end    

    def show
    end

    private

    def set_reservation 
      @reservation = Reservation.friendly.find(params[:reservation_slug])
      
      # Check if the current user is the owner or a member of the reservation
      unless @reservation.user_id == current_user.id || @reservation.members.include?(current_user)
        redirect_to request.referer, alert: "You don't have permission to check in to this reservation."
      end
    rescue ActiveRecord::RecordNotFound => e
      redirect_to request.referer, alert: "Reservation not found." 
    end

    def validate_reservation_status
      unless @reservation.pending?
        redirect_to reservation_path(@reservation), alert: "Cannot check in."
      end
    end

    def check_in_params
      params.require(:check_in).permit(:reservation_id, :user_id, :check_in_time)
    end
end

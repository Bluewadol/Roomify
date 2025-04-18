class Admin::CheckInsController < ApplicationController
    before_action :set_reservation, only: [:new, :create]
    before_action :validate_reservation_status, only: [:new, :create]

    def new
        @check_in = CheckIn.new(reservation_id: @reservation.id)
        Rails.logger.debug "Loaded reservation for check-in: #{@reservation.id}"
    end

    def create
        puts "🎯 ENTERED CREATE ACTION"
        @check_in = @reservation.build_check_in(check_in_params)
        Rails.logger.debug "Attempting to create check-in for reservation: #{@reservation.id}, check_in_params: #{check_in_params}"

        if @check_in.save
        @reservation.status = :checked_in
        @reservation.updated_by = current_user
        Rails.logger.debug "Check-in saved successfully. Updating reservation status to 'checked_in'."

        if @reservation.save
            Rails.logger.debug "Reservation updated successfully."
            redirect_to admin_reservation_path(@reservation), notice: 'Check-in successful.'
        else
            Rails.logger.error "Failed to save reservation status: #{@reservation.errors.full_messages.join(', ')}"
            @check_in.destroy
            redirect_to admin_reservation_path(@reservation), status: :unprocessable_entity, alert: 'Failed to update reservation status.'
        end
        else
            Rails.logger.error "Check-in creation failed: #{@check_in.errors.full_messages.join(', ')}"
            redirect_to admin_reservation_path(@reservation), status: :unprocessable_entity, alert: @check_in.errors.full_messages.join(', ')
        end
    end    

    def show
    end

    private

    def set_reservation 
        @reservation = Reservation.friendly.find(params[:reservation_slug])
        Rails.logger.debug "Loaded reservation with slug: #{params[:reservation_slug]} (Reservation ID: #{@reservation.id})"
    rescue ActiveRecord::RecordNotFound => e
        Rails.logger.error "Reservation with slug #{params[:reservation_slug]} not found: #{e.message}"
        redirect_to request.referer, alert: "Reservation not found." 
    end

    def validate_reservation_status
        unless @reservation.pending?
            redirect_to admin_reservation_path(@reservation), alert: "Cannot check in. Reservation is not in pending status."
        end
    end

    def check_in_params
        params.require(:check_in).permit(:reservation_id, :user_id, :check_in_time)
    end
end

class Admin::CheckInsController < Admin::BaseController
    before_action :set_reservation, only: [ :new, :create ]
    before_action :validate_reservation_status, only: [ :new, :create ]
    before_action :set_current_user, only: [ :new, :create ]

    def new
        @check_in = CheckIn.new(reservation_id: @reservation.id)
    end

    def create
        begin
        @check_in = @reservation.build_check_in(check_in_params)

        if @check_in.save
            @reservation.status = :checked_in
            @reservation.updated_by = current_user

            if @reservation.save
                redirect_to admin_reservation_path(@reservation), notice: "Check-in successful."
            else
                @check_in.destroy
                redirect_to admin_reservation_path(@reservation), alert: "Failed to update reservation status."
            end
        else
            redirect_to admin_reservation_path(@reservation), alert: @check_in.errors.full_messages.join(", ")
        end
        rescue => e
            redirect_to admin_reservation_path(@reservation), alert: "An error occurred: #{e.message}"
        end
    end

    def show
    end

    private

    def set_reservation
        @reservation = Reservation.friendly.find(params[:reservation_slug])
    rescue ActiveRecord::RecordNotFound
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

    def set_current_user
        @current_user = current_user
    end
end

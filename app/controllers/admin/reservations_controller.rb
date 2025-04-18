class Admin::ReservationsController < Admin::BaseController
    
    include ReservationFilterable
    
    before_action :set_reservation, only: %i[show edit update destroy]
    before_action :set_filter_params, only: [:new, :edit]

    def index
        # Get reservations created 
        @reservations = Reservation.includes(:room)
        
        # Add pagination for upcoming reservations
        upcoming_per_page = params[:upcoming_per_page].present? ? params[:upcoming_per_page].to_i : 5
        @upcoming_reservations = @reservations
            .where(status: [:pending, :in_use])
            .order(start_date: :desc, start_time: :desc)
        @upcoming_reservations = Kaminari.paginate_array(@upcoming_reservations).page(params[:upcoming_page]).per(upcoming_per_page)
        
        # Add pagination for past reservations
        past_per_page = params[:past_per_page].present? ? params[:past_per_page].to_i : 10
        @past_reservations = @reservations
            .where.not(status: [:pending, :in_use])
            .order(start_date: :desc, start_time: :desc)
        @past_reservations = Kaminari.paginate_array(@past_reservations).page(params[:past_page]).per(past_per_page)
    end  

    def show; end

    def new
        set_rooms()
        @reservation = Reservation.new
        @reservation.end_date = @reservation.start_date
        @room_select = Room.find_by(id: params[:room_id])
        @reservation.room_id = @room_select.id if @room_select
    end
    
    def create
        @reservation = current_user.reservations.build(reservation_params)
        @reservation.end_date = @reservation.start_date
        @reservation.updated_by = current_user
        set_rooms()
    
        if @reservation.save
            @reservation.members = User.where(id: params[:reservation][:member_ids].reject(&:blank?)) if params[:reservation][:member_ids]
            redirect_to admin_reservation_path(slug: @reservation.slug), notice: "Reservation was successfully created."
        else
            render :new, status: :unprocessable_entity
        end
    end  
    
    def edit        
        set_rooms(@reservation.id)
        @reservation.end_date = @reservation.start_date
        @room_select = Room.find_by(id: params[:room_id])
        @reservation.room_id = @room_select.id if @room_select
    end
    
    def update
        set_rooms(@reservation.id)
        @reservation.end_date = @reservation.start_date
        @reservation.updated_by = current_user
        if @reservation.update(reservation_params)
            @reservation.members = User.where(id: params[:reservation][:member_ids]) if params[:reservation][:member_ids]
            redirect_to admin_reservation_path(slug: @reservation.slug), notice: "Reservation was successfully updated."
        else
            render :edit, status: :unprocessable_entity
        end
    end

    def destroy
        @reservation.destroy
        redirect_to admin_reservations_path, notice: "Reservation was successfully deleted."
    end

    private

    def set_reservation
        @reservation = Reservation.friendly.find(params[:slug])
        
        rescue ActiveRecord::RecordNotFound
            redirect_to admin_reservations_path, alert: "Reservation not found." 
    end
    
    def reservation_params
        if params[:reservation][:status].present?
            params[:reservation][:status] = params[:reservation][:status].to_s.downcase.tr(' ', '_')
        end

        if params[:reservation][:start_date].present?
            params[:reservation][:end_date] = params[:reservation][:start_date]
        end
        
        params.require(:reservation).permit(
            :room_id,
            :start_date,
            :end_date,
            :start_time,
            :end_time,
            :description,
            :reservation_type,
            :status,
            member_ids: []
        )
        # params[:reservation][:end_date] = params[:reservation][:start_date]
    end
        
    
    def set_filter_params
        Time.zone = 'Bangkok'
        @start_date = params[:start_date].presence || Time.zone.today.to_s
        # @end_date   = params[:end_date].presence   || Time.zone.today.to_s
        @end_date   = params[:start_date].presence || Time.zone.today.to_s
        @start_time = parse_time_in_zone(@start_date, params[:start_time]) || parse_time_in_zone(Time.zone.today, Time.zone.now.strftime("%H:%M"))
        @end_time   = parse_time_in_zone(@end_date, params[:end_time]) || parse_time_in_zone(Time.zone.today, Time.zone.now.strftime("%H:%M"))
    end
    
    def set_rooms(current_reservation_id = nil)
        if params[:room_id].present?
            @room = Room.find_by(id: params[:room_id])
        elsif current_reservation_id.present?
            @room = @reservation.room
        end
    
        @rooms = Room.includes(:reservations, :room_amenities)

        @reservations_in_range = filter_reservations(Reservation.all, exclude_ids: current_reservation_id ? [current_reservation_id] : [])
        
        @rooms = filter_rooms(@rooms, @reservations_in_range, current_reservation_id: current_reservation_id)
        @rooms = sort_rooms_by_status(@rooms)

        per_page = params[:room_per_page].present? ? params[:room_per_page].to_i : 5
        @rooms = Kaminari.paginate_array(@rooms).page(params[:room_page]).per(per_page)
    end
end
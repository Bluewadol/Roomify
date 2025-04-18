class Admin::RoomsController < Admin::BaseController
    include ReservationFilterable

    before_action :set_room, only: [ :show, :edit, :update, :destroy ]
    before_action :set_filter_params, only: [:index]
    before_action :set_filter_room_details_params, only: [:show]

    def index
        @rooms = Room.includes(:reservations, :room_amenities)
        @maximum_capacity = @rooms&.maximum(:capacity_max) || 100
        @amenities = RoomAmenity.distinct.pluck(:amenity_name)
        
        # Filter reservations
        @reservations_in_range = filter_reservations(Reservation.all)
        
        # Filter and sort rooms
        @rooms = filter_rooms(@rooms, @reservations_in_range)
        @rooms = sort_rooms_by_status(@rooms)
        
        # Add pagination with custom per_page value
        per_page = params[:room_per_page].present? ? params[:room_per_page].to_i : 5
        @rooms = Kaminari.paginate_array(@rooms).page(params[:room_page]).per(per_page)
        
        @room_status = Room.statuses.keys 
    end

    def show
        @capacity_range = @room.capacity_min == @room.capacity_max ? @room.capacity_max : "#{@room.capacity_min} - #{@room.capacity_max}"
        
        # Filter reservations for this room
        @reservations_in_range = filter_reservations(Reservation.where(room_id: @room.id))
        @current_reservation = @reservations_in_range.where.not(status: [:canceled, :expired, :completed]).first
    
        # Determine room status
        status = determine_room_status(@room, @reservations_in_range)
        @room.assign_attributes(status: status)
        @room_status = Room.statuses.keys
        
        # Paginate reservations
        per_page = params[:reservation_per_page].present? ? params[:reservation_per_page].to_i : 5
        @reservations = @room.reservations.order(updated_at: :desc).page(params[:reservation_page]).per(per_page)
    end

    def new
        @room = Room.new
    end 

    def create
        @room = Room.new(room_params)
        @room.created_by = current_user
        @room.updated_by = current_user

        if @room.save
            redirect_to admin_rooms_path(slug: @room.slug), notice: "Room created successfully."
        else
            render :new, status: :unprocessable_entity
        end
    end

    def edit; end

    def update
        @room.updated_by = current_user
    
        if params[:room][:remove_image_ids]
            params[:room][:remove_image_ids].each do |image_id|
                image = @room.images.find(image_id)
                image.purge_later
            end
        end

        new_images = params[:room].delete(:images)
    
        if @room.update(room_params)
            @room.images.attach(new_images) if new_images.present?
            redirect_to admin_rooms_path(slug: @room.slug), notice: "Room updated successfully."
        else
            render :edit, status: :unprocessable_entity
        end
    end

    def destroy
        @room.qr_code.purge
        @room.destroy
        redirect_to admin_rooms_path, notice: "Room deleted successfully."
    end

    require 'zip'

    def download_all_qr_codes
        rooms = Room.includes(qr_code_attachment: :blob).where.not(active_storage_attachments: { id: nil })
        
        temp_file = Tempfile.new("room_qr_codes.zip")
        
        Zip::OutputStream.open(temp_file.path) do |zip|
            rooms.each do |room|
            next unless room.qr_code.attached?
        
            filename = "#{room.name.parameterize}-qr-code.png"
            blob = room.qr_code.blob
            file = blob.download
        
            zip.put_next_entry(filename)
            zip.write(file)
            end
        end
        
        send_data File.read(temp_file.path), filename: "all-room-qr-codes.zip", type: "application/zip"
    ensure
        temp_file.close
        temp_file.unlink
    end

    private

    def room_params
        params.require(:room).permit(:name, :capacity_min, :capacity_max, :description, images: [], 
            room_amenities_attributes: [:id, :amenity_name, :quantity, :_destroy])
    end

    def set_room
        @room = Room.friendly
                    .includes(:room_amenities)
                    .find(params[:slug])
                    
        @room.reservations = Reservation.where(room_id: @room.id).order(updated_at: :desc)
    rescue ActiveRecord::RecordNotFound
        redirect_to admin_rooms_path, alert: "Room not found."
    end   

    def set_filter_params
        Time.zone = 'Bangkok'
        @start_date = params[:start_date].presence || Time.zone.today.to_s
        @end_date   = params[:end_date].presence   || Time.zone.today.to_s
        @start_time = parse_time_in_zone(@start_date, params[:start_time])
        @end_time   = parse_time_in_zone(@end_date, params[:end_time])
        @selected_amenities = params[:amenities]&.reject(&:blank?) || []
        @selected_status = params[:room_status]&.reject(&:blank?) || []
        @room&.set_reference_datetime(@start_date, @start_time, @end_date, @end_time)
        Rails.logger.info("set_filter_params start_date: #{@start_date}")
        Rails.logger.info("set_filter_params end_date: #{@end_date}")
        Rails.logger.info("set_filter_params start_time: #{@start_time}")
        Rails.logger.info("set_filter_params end_time: #{@end_time}")
    end

    def set_filter_room_details_params
        Time.zone = 'Bangkok'
        @start_date = params[:start_date].presence || Time.zone.today.to_s
        @end_date   = params[:end_date].presence   || Time.zone.today.to_s
        @start_time = parse_time_in_zone(@start_date, params[:start_time]) || parse_time_in_zone(Time.zone.today, Time.zone.now.strftime("%H:%M"))
        @end_time   = parse_time_in_zone(@end_date, params[:end_time]) || parse_time_in_zone(Time.zone.today, Time.zone.now.strftime("%H:%M"))
        @selected_amenities = params[:amenities]&.reject(&:blank?) || []
        @selected_status = params[:room_status]&.reject(&:blank?) || []
        @room&.set_reference_datetime(@start_date, @start_time, @end_date, @end_time)
        Rails.logger.info("set_filter_room_details_params start_date: #{@start_date}")
        Rails.logger.info("set_filter_room_details_params end_date: #{@end_date}")
        Rails.logger.info("set_filter_room_details_params start_time: #{@start_time}")
        Rails.logger.info("set_filter_room_details_params end_time: #{@end_time}")
    end

    def apply_filters(rooms)
        rooms = filter_by_name(rooms) if params[:name].present?
        rooms = filter_by_capacity(rooms) if @capacity.present?
        rooms = filter_by_amenities(rooms) if @selected_amenities.present?

        rooms.map do |room|
            status = determine_room_status(room, @reservations_in_range)
            room.assign_attributes(status: status)
            room
        end
    end

    def filter_by_name(rooms)
        trimmed_name = params[:name].strip.downcase
        rooms.where("LOWER(name) LIKE ?", "%#{trimmed_name}%")
    end

    def filter_by_capacity(rooms)
        rooms.where("capacity_max >= ?", @capacity)
    end

    def filter_by_amenities(rooms)
        rooms.left_joins(:room_amenities)
                .where(room_amenities: { amenity_name: @selected_amenities })
    end

    def apply_status_filters(rooms)
        if @selected_status.present?
            rooms = rooms.select { |room| @selected_status.include?(room.status.to_s) }
        end

        if @selected_status == "booked"
            rooms = rooms.select do |room|
            booked = @reservations_in_range.where(room_id: room.id).exists?
            end
        end

        rooms
    end

    def sort_rooms_by_status(rooms)
        rooms.sort_by do |room|
            case room.status
            when 'available' then 0
            when 'booked' then 1
            when 'unavailable' then 2
            end
        end
    end
end


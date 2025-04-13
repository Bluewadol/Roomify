class Room < ApplicationRecord 
    before_validation :normalize_name
    extend FriendlyId
    
    friendly_id :name , use: :slugged

    has_many :room_amenities, dependent: :destroy

    has_one_attached :qr_code

    has_many_attached :images

    enum :status, { available: 0, unavailable: 1, booked: 2 }, default: :available

    has_many :reservations, dependent: :destroy

    belongs_to :created_by, class_name: "User"
    belongs_to :updated_by, class_name: "User"

    validates :name, presence: true, uniqueness: true
    validates :capacity_min, presence: true, numericality: { only_integer: true, greater_than: 0 }
    validates :capacity_max, presence: true, numericality: { only_integer: true, greater_than: 0 }
    validates :description, length: { maximum: 200 } 
    validate :validate_capacity_range
    # validates :qr_code, presence: true
    # validate :qr_code_must_be_image

    validates :images, presence: true
    validate :validate_images
    validate :images_count_within_limit

    after_create :generate_qr_code

    attr_accessor :reference_start_date, :reference_start_time, :reference_end_date, :reference_end_time

    def set_reference_datetime(date, time, end_date = nil, end_time = nil)
        @reference_start_date = date
        @reference_start_time = time
        @reference_end_date = end_date || date
        @reference_end_time = end_time || time
    end


    def next_reservation
        # Use the provided date and time parameters if available, otherwise use current time
        start_date = @reference_start_date || Time.current.in_time_zone('Asia/Bangkok').to_date
        start_time = @reference_start_time || Time.current.in_time_zone('Asia/Bangkok').strftime("%H:%M")
        end_date = @reference_end_date || start_date
        end_time = @reference_end_time || start_time
        
        Rails.logger.info("Reference start date: #{start_date}, Reference start time: #{start_time}")
        Rails.logger.info("Reference end date: #{end_date}, Reference end time: #{end_time}")

        reservations
            .where('(start_date > ?) OR (end_date > ?) OR (start_date = ? AND start_time > ?)', start_date, start_date, start_date, start_time)
            .where.not(status: [:canceled, :expired])
            .order(start_date: :asc, start_time: :asc)
            .first
    end

    def current_reservation
        if @current_reservation
            @current_reservation
        elsif reservations_in_range
            reservations_in_range.where.not(status: [:canceled, :expired, :completed]).first
        else
            # Fallback to current time if no date range is specified
            start_date = Time.current.in_time_zone('Asia/Bangkok').to_date
            start_time = Time.current.in_time_zone('Asia/Bangkok').strftime("%H:%M")
            
            reservations
                .where('start_date <= ? AND end_date >= ?', start_date, start_date)
                .where('start_time <= ? AND end_time > ?', start_time, start_time)
                .where.not(status: [:canceled, :expired, :completed])
                .first
        end
    end

    private

    def capacity_range
        return nil if capacity_min.nil? || capacity_max.nil?
        (capacity_min..capacity_max)
    end

    def validate_capacity_range
        return if capacity_min.nil? || capacity_max.nil?

        if capacity_min > capacity_max
            errors.add(:capacity_min, "cannot be greater than maximum capacity")
        end
    end

    # def qr_code_must_be_image
    #     return unless qr_code.attached?

    #     if !qr_code.content_type.in?(%w[image/jpeg image/png])
    #     errors.add(:qr_code, "must be a JPG or PNG image")
    #     end
    # end

    def validate_images
        images.each do |image|
            unless image.content_type.in?(%w[image/jpeg image/png image/webp])
            errors.add(:images, "ต้องเป็นไฟล์ JPEG, PNG หรือ WebP เท่านั้น")
            end
        end
    end

    def images_count_within_limit
        if images.count > 4
            errors.add(:images, "can't have more than 4 images")
        end
    end

    def generate_qr_code
        qr = RQRCode::QRCode.new(room_url)
        png = qr.as_png(size: 300)
    
        self.qr_code.attach(
            io: StringIO.new(png.to_s),
            filename: "room-#{id}-qr.png",
            content_type: 'image/png'
        )
    end
    
    def room_url
        Rails.application.routes.url_helpers.room_url(self, host: "http://127.0.0.1:3000/")
        # Rails.application.routes.url_helpers.checkin_url(host: "http://127.0.0.1:3000")
    end

    def should_generate_new_friendly_id?
        name_changed? || super
    end

    def normalize_name
        self.name = name.strip.gsub(/\s+/, ' ') if name.present?
    end
    
end

class Room < ApplicationRecord
    before_validation :normalize_name
    extend FriendlyId

    friendly_id :name, use: :slugged

    has_many :room_amenities, dependent: :destroy
    accepts_nested_attributes_for :room_amenities, allow_destroy: true

    has_one_attached :qr_code

    has_many_attached :images

    enum :status, { available: 0, unavailable: 1, booked: 2 }, default: :available

    has_many :reservations, dependent: :destroy

    belongs_to :created_by, class_name: "User"
    belongs_to :updated_by, class_name: "User"

    validates :name, presence: true,
                    uniqueness: { case_sensitive: false, message: "should be unique" },
                    length: { maximum: 50 }
    validates :capacity_min, presence: true, numericality: { only_integer: true, greater_than: 0 }
    validates :capacity_max, presence: true, numericality: { only_integer: true, greater_than: 0 }
    validates :description, length: { maximum: 200 }
    validate :validate_capacity_range

    validate :validate_images
    validate :images_count_within_limit
    validate :capacity_max_greater_than_min
    validate :no_duplicate_amenity_names

    after_create :generate_qr_code

    attr_accessor :reference_start_date, :reference_start_time, :reference_end_date, :reference_end_time

    # enum room_type: {
    #     meeting_room: "meeting_room",
    #     conference_room: "conference_room",
    #     training_room: "training_room",
    #     private_office: "private_office",
    #     shared_workspace: "shared_workspace"
    # }

    def set_reference_datetime(date, time, end_date = nil, end_time = nil)
        @reference_start_date = date
        @reference_start_time = time
        @reference_end_date = end_date || date
        @reference_end_time = end_time || time
    end

    def next_reservation
        start_date = @reference_start_date || Time.current.in_time_zone("Asia/Bangkok").to_date
        start_time = @reference_start_time || Time.current.in_time_zone("Asia/Bangkok").strftime("%H:%M")
        end_date = @reference_end_date || start_date
        end_time = @reference_end_time || start_time

        Rails.logger.info("Reference start date: #{start_date}, Reference start time: #{start_time}")
        Rails.logger.info("Reference end date: #{end_date}, Reference end time: #{end_time}")

        reservations
            .where("(start_date > ?) OR (end_date > ?) OR (start_date = ? AND start_time > ?) OR (end_date = ? AND start_time > ?)", start_date, start_date, start_date, start_time, start_date, start_time)
            .where.not(status: [ :canceled, :expired, :completed ])
            .order(start_date: :asc, start_time: :asc)
            .first
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

    def validate_images
        new_images = images.attachments.select(&:new_record?)
        return if new_images.blank?

        new_images.each do |image|
            unless image.content_type.in?(%w[image/jpeg image/png image/webp])
            errors.add(:images, "must be a JPEG, PNG, or WebP image")
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
            content_type: "image/png"
        )
    end

    def room_url
        # Rails.application.routes.url_helpers.room_url(self, host: "https://roomify-odds.onrender.com/")
        Rails.application.routes.url_helpers.room_url(self)
      # Rails.application.routes.url_helpers.checkin_url(host: "http://127.0.0.1:3000")
    end

    def should_generate_new_friendly_id?
        name_changed? || super
    end

    def normalize_name
        self.name = name.strip if name.present?
    end

    def capacity_max_greater_than_min
        return unless capacity_min.present? && capacity_max.present?
        if capacity_max < capacity_min
            errors.add(:capacity_max, "must be greater than or equal to minimum capacity")
        end
    end

    def no_duplicate_amenity_names
        return unless room_amenities.any?

        amenity_names = room_amenities.map { |amenity| amenity.amenity_name.to_s.downcase.gsub(/\s+/, "") }
        duplicate_names = amenity_names.select { |name| amenity_names.count(name) > 1 }.uniq

        if duplicate_names.any?
            duplicate_names.each do |name|
                errors.add(:base, "Amenity name '#{name}' is duplicated (ignoring spaces and case)")

                room_amenities.each do |amenity|
                    if amenity.amenity_name.to_s.downcase.gsub(/\s+/, "") == name
                        amenity.errors.add(:amenity_name, "should be unique (ignoring spaces and case)")
                    end
                end
            end
        end
    end
end

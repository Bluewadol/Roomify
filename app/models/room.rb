class Room < ApplicationRecord
    has_many :room_amenities, dependent: :destroy

    has_one_attached :qr_code

    has_many_attached :images

    enum :status, { available: 0, booked: 1, unavailable: 2 }, default: :available

    validates :name, presence: true, uniqueness: true
    validates :capacity_min, presence: true, numericality: { only_integer: true, greater_than: 0 }
    validates :capacity_max, presence: true, numericality: { only_integer: true, greater_than: 0 }
    validate :validate_capacity_range
    validates :qr_code, presence: true
    validate :qr_code_must_be_image

    validates :images, presence: true
    validate :validate_images
    validate :images_count_within_limit

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

    def qr_code_must_be_image
        return unless qr_code.attached?

        if !qr_code.content_type.in?(%w[image/jpeg image/png])
        errors.add(:qr_code, "must be a JPG or PNG image")
        end
    end

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
    
end

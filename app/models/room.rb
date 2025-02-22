class Room < ApplicationRecord
    has_many :room_amenities, dependent: :destroy

    has_one_attached :qr_code

    enum :status, { available: 0, booked: 1, unavailable: 2 }, default: :available

    validates :name, presence: true, uniqueness: true
    validates :capacity_min, presence: true, numericality: { only_integer: true, greater_than: 0 }
    validates :capacity_max, presence: true, numericality: { only_integer: true, greater_than: 0 }
    validate :validate_capacity_range

    def capacity_range
        return nil if capacity_min.nil? || capacity_max.nil?
        (capacity_min..capacity_max)
    end

    private

    def validate_capacity_range
        return if capacity_min.nil? || capacity_max.nil?

        if capacity_min > capacity_max
            errors.add(:capacity_min, "cannot be greater than maximum capacity")
        end
    end
end

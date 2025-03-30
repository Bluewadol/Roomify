class RoomAmenity < ApplicationRecord
  belongs_to :room

  validates :amenity_name, presence: true,
                            length: { maximum: 50, message: "should be less than 50 characters" }
  
  validates :quantity, numericality: { only_integer: true, greater_than: 0 }

  validate :unique_amenity_name_within_room

  private

  def unique_amenity_name_within_room
    return unless amenity_name.present?

    normalized_name = amenity_name.downcase.gsub(/\s+/, '')
    if RoomAmenity.where("REPLACE(LOWER(amenity_name), ' ', '') = ? AND room_id = ?", normalized_name, room_id)
                  .where.not(id: id)
                  .exists?
      errors.add(:amenity_name, "should be unique within the same room (ignoring spaces and case)")
    end
  end
end

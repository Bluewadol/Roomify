class RoomAmenity < ApplicationRecord
  belongs_to :room

  validates :amenity_name, presence: true, uniqueness: true
  validates :quantity, numericality: { only_integer: true, greater_than: 0 }
end

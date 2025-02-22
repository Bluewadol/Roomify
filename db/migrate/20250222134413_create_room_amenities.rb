class CreateRoomAmenities < ActiveRecord::Migration[8.0]
  def change
    create_table :room_amenities do |t|
      t.references :room, null: false, foreign_key: true
      t.string :amenity_name
      t.integer :quantity

      t.timestamps
    end
  end
end

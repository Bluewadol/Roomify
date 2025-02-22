class CreateRooms < ActiveRecord::Migration[8.0]
  def change
    create_table :rooms do |t|
      t.string :name
      t.integer :capacity
      t.integer :status
      t.string :qr_code

      t.timestamps
    end
  end
end

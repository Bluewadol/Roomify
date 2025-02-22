class UpdateRoomsCapacity < ActiveRecord::Migration[7.0]
  def change
    remove_column :rooms, :capacity, :integer
    add_column :rooms, :capacity_min, :integer, null: false, default: 1
    add_column :rooms, :capacity_max, :integer, null: false, default: 1
  end
end

class AddCreatedByAndUpdatedByToRooms < ActiveRecord::Migration[7.0]
  def change
    add_reference :rooms, :created_by, foreign_key: { to_table: :users }, null: false
    add_reference :rooms, :updated_by, foreign_key: { to_table: :users }, null: false
  end
end

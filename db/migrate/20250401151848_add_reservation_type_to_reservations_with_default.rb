class AddReservationTypeToReservationsWithDefault < ActiveRecord::Migration[7.0]
  def change
    add_column :reservations, :reservation_type, :integer, default: 4, null: false
  end
end

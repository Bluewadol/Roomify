class AddUpdatedByToReservations < ActiveRecord::Migration[7.1]
  def change
    add_reference :reservations, :updated_by, foreign_key: { to_table: :users }
  end
end

class CreateReservations < ActiveRecord::Migration[8.0]
  def change
    create_table :reservations do |t|
      t.references :user, null: false, foreign_key: true
      t.references :room, null: false, foreign_key: true
      t.date :date
      t.time :start_time
      t.time :end_time
      t.integer :status, default: 0, null: false

      t.timestamps
    end
  end
end

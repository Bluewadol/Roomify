class CreateReservationSubscribers < ActiveRecord::Migration[7.1]
  def change
    create_table :reservation_subscribers do |t|
      t.references :reservation, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :order, null: false

      t.timestamps
    end

    add_index :reservation_subscribers, [:reservation_id, :user_id], unique: true
  end
end 
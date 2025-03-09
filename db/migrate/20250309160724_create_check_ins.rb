class CreateCheckIns < ActiveRecord::Migration[8.0]
  def change
    create_table :check_ins do |t|
      t.references :reservation, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.datetime :check_in_time

      t.timestamps
    end
  end
end

class AddStartDateAndEndDateAdnDescriptionToReservations < ActiveRecord::Migration[8.0]
  def change
    remove_column :reservations, :date
    add_column :reservations, :start_date, :date
    add_column :reservations, :end_date, :date
    add_column :reservations, :description, :text
  end
end

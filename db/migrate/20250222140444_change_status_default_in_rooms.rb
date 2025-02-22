class ChangeStatusDefaultInRooms < ActiveRecord::Migration[7.0]
  def change
    change_column_default :rooms, :status, 0
  end
end

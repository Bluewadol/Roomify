class RemoveQrCodeFromRooms < ActiveRecord::Migration[6.0]
  def change
    remove_column :rooms, :qr_code, :string
  end
end

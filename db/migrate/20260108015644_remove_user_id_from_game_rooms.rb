class RemoveUserIdFromGameRooms < ActiveRecord::Migration[7.1]
  def change
    remove_column :game_rooms, :user_id, :bigint
  end
end

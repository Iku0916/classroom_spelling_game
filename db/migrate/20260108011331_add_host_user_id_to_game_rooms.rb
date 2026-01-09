class AddHostUserIdToGameRooms < ActiveRecord::Migration[7.1]
  def change
    add_column :game_rooms, :host_user_id, :bigint
    add_index :game_rooms, :host_user_id
    add_foreign_key :game_rooms, :users, column: :host_user_id
  end
end

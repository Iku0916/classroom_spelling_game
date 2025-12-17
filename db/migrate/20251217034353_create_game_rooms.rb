class CreateGameRooms < ActiveRecord::Migration[7.1]
  def change
    create_table :game_rooms do |t|
      t.string :game_code
      t.integer :status
      t.datetime :started_at
      t.datetime :finished_at
      t.integer :time_limit
      t.references :user, null: false, foreign_key: true
      t.references :word_kit, null: false, foreign_key: true
      t.timestamps
    end
  end
end

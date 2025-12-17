class CreateParticipants < ActiveRecord::Migration[7.1]
  def change
    create_table :participants do |t|
      t.string :nickname, null: false
      t.integer :score, default: 0
      t.boolean :is_ready
      t.references :game_room, null: false, foreign_key: true
      t.references :guest, foreign_key: true
      t.references :user, foreign_key: true
      t.timestamps
    end
  end
end

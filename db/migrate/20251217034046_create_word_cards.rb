class CreateWordCards < ActiveRecord::Migration[7.1]
  def change
    create_table :word_cards do |t|
      t.string :english_word
      t.string :japanese_translation
      t.references :word_kit, null: false, foreign_key: true
      t.timestamps
    end
  end
end

class CreateWordKitTags < ActiveRecord::Migration[7.1]
  def change
    create_table :word_kit_tags do |t|
      t.references :word_kit, null: false, foreign_key: true
      t.references :tag, null: false, foreign_key: true

      t.timestamps
    end

    add_index :word_kit_tags, [:word_kit_id, :tag_id], unique: true
  end
end

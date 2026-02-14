class AddStatusToWordKits < ActiveRecord::Migration[7.1]
  def change
    add_column :word_kits, :status, :integer, default: 0, null: false
  end
end

# frozen_string_literal: true

class AddUuidToWordKits < ActiveRecord::Migration[7.1]
  def change
    add_column :word_kits, :uuid, :string, null: false, default: -> { 'gen_random_uuid()' }
    add_index :word_kits, :uuid, unique: true
  end
end

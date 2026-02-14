class RenameStatusToVisibilityInWordKits < ActiveRecord::Migration[7.1]
  def change
    rename_column :word_kits, :status, :visibility
  end
end

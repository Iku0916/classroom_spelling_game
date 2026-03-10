# frozen_string_literal: true

class AddTotalScoreToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :total_score, :integer
  end
end

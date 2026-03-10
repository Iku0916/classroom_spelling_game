# frozen_string_literal: true

class ChangeWordKitIdInLearningLogsToNullable < ActiveRecord::Migration[7.1]
  def change
    change_column_null :learning_logs, :word_kit_id, true
  end
end

class ChangeWordKitIdNotNullOnLearningLogs < ActiveRecord::Migration[7.1]
  def change
    change_column_null :learning_logs, :word_kit_id, false
  end
end

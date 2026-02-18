class AddWordKitToLearningLogs < ActiveRecord::Migration[7.1]
  def change
    add_reference :learning_logs, :word_kit, null: true, foreign_key: true
  end
end

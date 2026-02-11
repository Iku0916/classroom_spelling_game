class AddMinutesToLearningLogs < ActiveRecord::Migration[7.1]
  def change
    add_column :learning_logs, :minutes, :integer
  end
end

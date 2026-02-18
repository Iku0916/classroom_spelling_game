class LearningLogsController < ApplicationController
  before_action :authenticate_user!

  def answer
    current_user.learning_logs.create!(learning_log_params)
    head :ok
  end

  private

  def learning_log_params
    params.require(:learning_log).permit(:minutes, :score, :word_kit_id)
  end
end

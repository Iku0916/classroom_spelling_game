class LearningLogsController < ApplicationController
  before_action :authenticate_user!

  def answer
    LearningLog.create!(
      user: current_user,
      minutes: learning_log_params[:minutes],
      score: learning_log_params[:score],
      word_kit_id: params[:word_kit_id]
    )
    head :ok
  end

  private

  def learning_log_params
    params.require(:learning_log).permit(:minutes, :score)
  end
end

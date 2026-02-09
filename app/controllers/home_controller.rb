class HomeController < ApplicationController
  def index
    if logged_in?
      @user = current_user
      @learning_logs = @user.learning_logs.order(created_at: :asc)
      
      @score_by_day = @learning_logs.group_by { |log| log.created_at.to_date }
                                    .transform_values { |logs| logs.sum(&:score) }
    else
      @score_by_day = {}
    end
  end
end

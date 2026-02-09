class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    
    if @user.save
      redirect_to login_path, notice: '新規登録が完了しました！'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @user = current_user

    @learning_logs = @user.learning_logs.order(created_at: :asc)
    @score_by_day = @learning_logs.group_by { |log| log.created_at.to_date }
                                .transform_values { |logs| logs.sum(&:score) }
  end                 

  private

  def user_params
    params.require(:user).permit(:name, :email, :password)
  end
end

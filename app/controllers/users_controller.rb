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
    @score_by_day = @learning_logs.group_by { |log| log.created_at.in_time_zone('Tokyo').to_date }
                                .transform_values { |logs| logs.sum(&:score) }
  end                 

  def edit
    @user = current_user
  end

  def update
    @user = current_user

    if params[:user][:password].blank?
      params[:user].delete(:password)
      params[:user].delete(:password_confirmation)
    end

    if @user.update(user_params)
      redirect_to root_path, notice: "設定を更新しました！"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end

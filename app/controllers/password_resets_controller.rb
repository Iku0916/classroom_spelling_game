class PasswordResetsController < ApplicationController

  def new; end

  def create
    @user = User.find_by(email: params[:email])
    if @user
      @user.generate_reset_password_token! 
      UserMailer.reset_password_email(@user).deliver_now
    end

    redirect_to login_path, notice: 'メールを送信しました。ご確認ください。'
  end

  def edit
    @token = params[:id]
    @user = User.load_from_reset_password_token(@token)
    not_authenticated if @user.blank?
  end

  def update
    @token = params[:id]
    @user = User.load_from_reset_password_token(@token)

    return not_authenticated if @user.blank?

    @user.password_confirmation = params[:user][:password_confirmation]
    if @user.change_password(params[:user][:password])
      redirect_to login_path, notice: 'パスワードを変更しました。'
    else
      flash.now[:danger] = 'パスワード変更を失敗しました。'
      render :edit, status: :unprocessable_entity
    end
  end
end

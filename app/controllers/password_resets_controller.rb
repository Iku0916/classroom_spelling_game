# frozen_string_literal: true

class PasswordResetsController < ApplicationController
  def new; end

  def create
    @user = User.find_by(email: params[:email])
    if @user
      @user.generate_reset_password_token!
      @user.save!
      UserMailer.reset_password_email(@user, @user.reset_password_token).deliver_now
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

    if @user.change_password(user_params[:password])
      redirect_to login_path, notice: 'パスワードを変更しました。'
    else
      handle_update_failure
    end
  end

  private

  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  def handle_update_failure
    flash.now[:alert] = 'パスワード変更を失敗しました。'
    render :edit, status: :unprocessable_entity
  end
end

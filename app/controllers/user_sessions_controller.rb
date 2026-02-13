class UserSessionsController < ApplicationController
  def new
  end

  def create
    @user = login(params[:email], params[:password])
    if @user
      if @user.onboarding_seen
        redirect_to root_path
      else
        redirect_to onboarding_path
      end
    else
      flash.now[:alert] = "メールアドレスかパスワードが違います"
      render :new
    end
  end

  def destroy
    logout
    redirect_to root_path
  end
end
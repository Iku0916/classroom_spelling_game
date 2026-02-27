class OauthsController < ApplicationController
  skip_before_action :require_login, raise: false

  def oauth
    login_at(params[:provider])
  end

  def callback
    provider = params[:provider]
    if @user = login_from(provider)
      redirect_to root_path, notice: "#{provider.titleize}でログインしました"
    else
      begin
        # Googleのデータでユーザー作成（パスワードはランダムで自動生成されるよ）
        @user = create_from(provider)
        reset_session
        auto_login(@user)
        redirect_to root_path, notice: "#{provider.titleize}でログインしました"
      rescue
        redirect_to login_path, alert: "#{provider.titleize}でのログインに失敗しました"
      end
    end
  end
end

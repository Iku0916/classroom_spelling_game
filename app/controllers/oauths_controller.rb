# frozen_string_literal: true

class OauthsController < ApplicationController
  skip_before_action :require_login, raise: false

  def oauth
    login_at(params[:provider])
  end

  def callback
    provider = params[:provider]
    Rails.logger.info '🔥 CALLBACK START'

    if (@user = login_from(provider))
      Rails.logger.info '🔥 login_from success'
      redirect_to root_path, notice: "#{provider.titleize}でログインしました"
    else
      Rails.logger.info '🔥 login_from failed'

      @user = create_from(provider)
      Rails.logger.info "🔥 create_from result: #{@user.inspect}"

      if @user.persisted?
        auto_login(@user)
        Rails.logger.info '🔥 auto_login done'
        redirect_to root_path, notice: "#{provider.titleize}でログインしました"
      else
        Rails.logger.info '🔥 user not persisted'
        redirect_to login_path, alert: '保存失敗'
      end
    end
  end
end

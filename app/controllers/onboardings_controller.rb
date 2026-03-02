class OnboardingsController < ApplicationController
  before_action :require_login
  before_action :check_onboarding

  def show
  end

  def complete
    current_user.update(onboarding_seen: true)
    head :ok
  end

  private

  def check_onboarding
    if current_user.onboarding_seen && params[:force] != "true"
      redirect_to root_path
    end
  end
end

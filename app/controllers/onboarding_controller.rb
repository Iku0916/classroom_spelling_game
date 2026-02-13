class OnboardingController < ApplicationController
  before_action :require_login
  before_action :check_onboarding

  def index
  end

  def complete
    current_user.update(onboarding_seen: true)
    head :ok
  end

  private

  def check_onboarding
    redirect_to root_path if current_user.onboarding_seen
  end
end

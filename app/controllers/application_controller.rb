# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Sorcery::Controller

  def current_guest
    return @current_guest if defined?(@current_guest)

    guest_id = session[:guest_id]
    @current_guest = guest_id ? Guest.find_by(id: guest_id) : nil
    @current_guest
  end
  helper_method :current_guest

  private

  def not_authenticated
    redirect_to login_path, alert: 'ログインしてください'
  end
end

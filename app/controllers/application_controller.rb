# frozen_string_literal: true

class ApplicationController < ActionController::Base
  rescue_from ActiveRecord::RecordNotFound, with: :render_404
  rescue_from ActionController::RoutingError, with: :render_404

  include Sorcery::Controller

  def current_guest
    return @current_guest if defined?(@current_guest)

    guest_id = session[:guest_id]
    @current_guest = guest_id ? Guest.find_by(id: guest_id) : nil
    @current_guest
  end
  helper_method :current_guest


  def render_404
    render file: Rails.root.join('public/404.html'), status: :not_found, layout: false
  end

  private

  def not_authenticated
    redirect_to login_path, alert: 'ログインしてください'
  end
end

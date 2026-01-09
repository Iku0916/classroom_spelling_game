class GameChannel < ApplicationCable::Channel
  def subscribed
    game_room_id = params[:game_room_id]
    stream_from "game_channel_#{game_room_id}"
    Rails.logger.info "✅ GameChannel subscribed: game_channel_#{game_room_id}"
  end

  def unsubscribed
    Rails.logger.info "❌ GameChannel unsubscribed"
  end
end
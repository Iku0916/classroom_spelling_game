class GameChannel < ApplicationCable::Channel
  def subscribed
    room_id = params[:room_id]
    stream_from "game_room_#{room_id}"
    Rails.logger.info "=== GameChannel subscribed: room_#{room_id} ==="
  end

  def unsubscribed
    Rails.logger.info "=== GameChannel unsubscribed ==="
  end
end

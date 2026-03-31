# frozen_string_literal: true

class GameChannel < ApplicationCable::Channel
  def subscribed
    game_room_id = params[:game_room_id]
    stream_from "game_channel_#{game_room_id}"
  end
end

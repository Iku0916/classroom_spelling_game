module ApplicationCable
  class Channel < ActionCable::Channel::Base
    def subscribed
      stream_from "game_room_1"
    end
  end
end

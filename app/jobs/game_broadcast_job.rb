class GameBroadcastJob < ApplicationJob
  queue_as :default

  def perform(room, message)
    ActionCable.server.broadcast(
      "game_room_#{room}",
      message: message
    )
  end

  def start
    @game_room.update(status: :playing)
    GameBroadcastJob.perform_later(
      @game_room.id,
      { url: game_room_answer_path(@game_room, @answer)}
    )
  end
end

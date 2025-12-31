class GameRoomsController < ApplicationController

  def create
    @game_room = current_user.game_rooms.create!(
      game_code: SecureRandom.alphanumeric(6),
      status: :waiting,
      time_limit: 5,
      word_kit_id: params[:word_kit_id]
    )
    redirect_to game_room_path(@game_room)
  end

  def show
    @game_room = GameRoom.find(params[:game_room_id])
    @word_kit = @game_room.word_kit
    @questions = @word_kit.word_cards
  end

  def update
    @game_room = GameRoom.find(params[:id])
    if @game_room.update(game_room_params)
      redirect_to game_room_path(@game_room)
    else
      redirect_to game_kits_path
    end
  end

  def start
    @game_room = GameRoom.find(params[:id])
    if request.patch?
      @game_room.update(status: 'playing', time_limit: params[:time_limit])
      @game_room.participants.where(is_ready: true).exists?
      word_kit = @game_room.word_kit 
        Rails.logger.debug "=== ブロードキャスト実行 ==="
        ActionCable.server.broadcast("game_room_#{@game_room.id}", 
        {
          type: "game_start",
          message: "ゲームが始まりました",
          redirect_url: word_kit_path(@game_room.word_kit, game_room_id: @game_room.id)
        }
        )
      Rails.logger.debug "=== ブロードキャスト完了 ==="
      redirect_to start_game_room_path(@game_room)
    elsif request.get?
      @questions = @game_room.word_kit.word_cards
    else
      redirect_to game_room_path(@game_room), alert: '準備完了の参加者がいません'
    end
  end

  def waiting
    @game_room = GameRoom.find(params[:id])
  end

  def finish
    @game_room = GameRoom.find(params[:id])
    @game_room.update(status: 'finished')
    redirect_to root_path
  end

  def answer
    @answer = params[:answer]
  end

  private

  def game_room_params
    params.require(:game_room).permit(:time_limit, :status)
  end
end

class GameRoomsController < ApplicationController

  def index
    @game_room = GameRoom.all
  end

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
    @game_room = GameRoom.find(params[:id])
  end

  def update
    @game_room = GameRoom.find(params[:id])
    if @game_room.update(game_room_params)
      redirect_to game_room_path(@game_room)
    else
      redirect_to game_kits_path
    end
  end

  # def start
  #   @game_room = GameRoom.find(params[:id])
  #   if @game_room.update(status: 'playing', time_limit: params[:time_limit])
  #     redirect_to game_room_path(@game_room)
  #   else
  #     redirect_to waiting_game_room_path(@game_room)
  #   end
  # end
  def start
    @game_room = GameRoom.find(params[:id])
    puts "=== START ACTION ==="
    puts @game_room.inspect
    @game_room.update(status: 'playing', time_limit: params[:time_limit])
    redirect_to game_room_path(@game_room)
  end

  def waiting
  end

  private

  def game_room_params
    params.require(:game_room).permit(:time_limit, :status)
  end
end

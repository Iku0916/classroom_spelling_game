class ParticipantsController < ApplicationController
  def index
  end

  def create
    @game_room = GameRoom.find_by(game_code: params[:game_code])
    if @game_room
      Participant.create(
        nickname: session[:nickname],
        game_room: @game_room,
        is_ready: true
      )
      redirect_to waiting_game_room_path(@game_room)
    else
      flash[:alert] = "無効なゲームコードです"
      render :new
    end
  end
end

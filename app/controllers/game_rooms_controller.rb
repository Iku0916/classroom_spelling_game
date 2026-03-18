# frozen_string_literal: true

class GameRoomsController < ApplicationController
  before_action :require_login, except: %i[join show waiting]

  def create
    @game_room = GameRoom.build_with_host(current_user, params[:word_kit_id])

    if @game_room.save
      @game_room.participants.create!(user_id: current_user&.id)
      redirect_to game_room_path(@game_room), notice: 'ゲームルームを作成しました'
    else
      redirect_to word_kits_path, alert: 'ゲームルームの作成に失敗しました'
    end
  end

  def join
    @game_room = GameRoom.find(params[:id])
    participant = @game_room.participants.build(participant_params)

    if participant.save
      @game_room.broadcast_participant_joined(participant)
      redirect_to waiting_game_room_path(@game_room), notice: '参加しました!'
    else
      redirect_to game_room_path(@game_room), alert: '参加に失敗しました'
    end
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

  def start
    @game_room = GameRoom.find(params[:id])

    if request.get?
      @questions = @game_room.word_kit.word_cards
      return
    end

    if @game_room.ready_participants?
      @game_room.start_game!(params[:time_limit])
      redirect_to start_game_room_path(@game_room), status: :see_other
    else
      redirect_to game_room_path(@game_room), alert: '準備完了の参加者がいません'
    end
  end

  def next_step_url(index, total_count, game_room)
    if index >= total_count
      Rails.application.routes.url_helpers.result_game_room_game_play_path(game_room)
    else
      Rails.application.routes.url_helpers.game_room_game_play_path(game_room)
    end
  end

  def waiting
    @game_room = GameRoom.find(params[:id])
  end

  def finish
    @game_room = GameRoom.find(params[:id])
    @game_room.finish_game!

    render json: { success: true }
  end

  private

  def game_room_params
    params.require(:game_room).permit(:time_limit, :status)
  end

  def participant_params
    params.require(:participant).permit(:nickname, :user_id, :guest_id, :is_ready, :score)
  end
end

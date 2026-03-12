# frozen_string_literal: true

class ParticipantsController < ApplicationController
  def new
    @participant = Participant.new
  end

  def create
    @game_room = find_game_room(params[:game_code])
    return unless @game_room

    @participant = Participant.build_for_game(@game_room, params, current_user, session)

    if @participant.save
      handle_successful_join
    else
      handle_failed_join
    end
  end

  def personal_result
    @participant = Participant.find(params[:id])
    @game_room = @participant.game_room
    @my_rank = @game_room.participants.where('score > ?', @participant.score).count + 1
    @total_participants = @game_room.participants.count
  end

  private

  def handle_successful_join
    broadcast_join(@participant)
    redirect_to waiting_game_room_path(@game_room), notice: 'ゲームに参加しました'
  end

  def broadcast_join(participant)
    ActionCable.server.broadcast(
      "game_channel_#{participant.game_room_id}",
      {
        type: 'participant_joined',
        participant: { id: participant.id, nickname: participant.nickname },
        participants_count: participant.game_room.participants.count
      }
    )
  end

  def find_game_room(code)
    room = GameRoom.find_by(game_code: code)
    return room if room

    flash.now[:alert] = '無効なゲームコードです'
    @participant = Participant.new
    render :new, status: :unprocessable_entity
    nil
  end

  def handle_failed_join
    flash.now[:alert] = '参加に失敗しました'
    render :new, status: :unprocessable_entity
  end
end

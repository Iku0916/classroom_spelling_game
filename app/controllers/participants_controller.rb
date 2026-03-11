# frozen_string_literal: true

class ParticipantsController < ApplicationController
  def new; end

  def create
    @game_room = GameRoom.find_by(game_code: params[:game_code])

    unless @game_room
      flash[:alert] = '無効なゲームコードです'
      redirect_to participants_path
      return
    end

    if current_user
      @participant = @game_room.participants.build(
        user: current_user,
        nickname: params[:nickname].presence || current_user.name || "プレイヤー#{current_user.id}",
        is_ready: true,
        score: 0
      )
    else
      guest = Guest.create!(session_token: SecureRandom.urlsafe_base64)
      session[:guest_id] = guest.id

      @participant = @game_room.participants.build(
        guest: guest,
        nickname: params[:nickname].presence || "ゲスト#{guest.id}",
        is_ready: true,
        score: 0
      )
    end

    if @participant.save
      ActionCable.server.broadcast(
        "game_channel_#{@game_room.id}",
        {
          type: 'participant_joined',
          participant: {
            id: @participant.id,
            nickname: @participant.nickname
          },
          participants_count: @game_room.participants.count
        }
      )
      redirect_to waiting_game_room_path(@game_room), notice: 'ゲームに参加しました'
    else
      flash[:alert] = "参加に失敗しました: #{@participant.errors.full_messages.join(', ')}"
      redirect_to new_participant_path
    end
  end

  def personal_result
    @participant = Participant.find(params[:id])
    @game_room = @participant.game_room
    @my_rank = @game_room.participants.where('score > ?', @participant.score).count + 1
    @total_participants = @game_room.participants.count
  end
end

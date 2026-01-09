class ParticipantsController < ApplicationController
  def new
  end

  def create
    @game_room = GameRoom.find_by(game_code: params[:game_code])

    unless @game_room
      flash[:alert] = "無効なゲームコードです"
      redirect_to participants_path
      return  # ← ここを別の行に分ける
    end

    if current_user
      # ログインユーザーの場合
      @participant = @game_room.participants.build(
        user: current_user,
        nickname: params[:nickname].presence || current_user.name || "プレイヤー#{current_user.id}",
        is_ready: true,
        score: 0
      )
      Rails.logger.debug "=== User として参加: #{current_user.id} ==="
    else
      # ゲストユーザーの場合
      guest = Guest.create!(session_token: SecureRandom.urlsafe_base64)
      session[:guest_id] = guest.id
      
      Rails.logger.debug "=== Guest 作成: #{guest.id} ==="
      Rails.logger.debug "=== session[:guest_id] に保存: #{session[:guest_id]} ==="
      
      @participant = @game_room.participants.build(
        guest: guest,
        nickname: params[:nickname].presence || "ゲスト#{guest.id}",
        is_ready: true,
        score: 0
      )
    end

    if @participant.save
      Rails.logger.info "✅ 参加者を作成: #{@participant.inspect}"
      redirect_to waiting_game_room_path(@game_room), notice: "ゲームに参加しました"
    else
      Rails.logger.error "❌ 参加者作成失敗: #{@participant.errors.full_messages}"
      flash[:alert] = "参加に失敗しました: #{@participant.errors.full_messages.join(', ')}"
      redirect_to new_participant_path
    end
  end

  def personal_result
    @participant = Participant.find(params[:id])
    @game_room = @participant.game_room
    @my_rank = @game_room.participants.where('score > ?', @participant.score).count + 1
    @total_participants = @game_room.participants.count

    Rails.logger.info "=== Participant result: #{@participant.id}, score: #{@participant.score} ==="
  end
end

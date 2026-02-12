class GameRoomsController < ApplicationController
  before_action :require_login, except: [:join, :show, :waiting]

  def create
    @game_room = GameRoom.new(
      host_user: current_user,
      game_code: SecureRandom.random_number(10**6).to_s.rjust(6, "0"),
      status: :waiting,
      time_limit: 300,
      word_kit_id: params[:word_kit_id]
    )

    # デバッグ用のログを追加
    Rails.logger.debug "===== GameRoom Attributes ====="
    Rails.logger.debug "@game_room.attributes: #{@game_room.attributes.inspect}"
    Rails.logger.debug "@game_room.valid?: #{@game_room.valid?}"
    
    unless @game_room.valid?
      Rails.logger.debug "===== Validation Errors ====="
      Rails.logger.debug "@game_room.errors.full_messages: #{@game_room.errors.full_messages}"
    end

    if @game_room.save
      @game_room.participants.create!(
      user_id: current_user&.id,
      )
      redirect_to game_room_path(@game_room), notice: 'ゲームルームを作成しました'
    else
      Rails.logger.debug "===== Save Failed ====="
      Rails.logger.debug "@game_room.errors: #{@game_room.errors.full_messages}"
      flash[:alert] = 'ゲームルームの作成に失敗しました'
      redirect_to word_kits_path
    end
  end

  def join
    @game_room = GameRoom.find(params[:id])

    participant = @game_room.participants.build(
    user_id: current_user&.id,
    guest_id: current_guest&.id,
    nickname: params[:nickname] || current_user&.name || 'ゲスト',
    is_ready: false
  )
  
    if participant.save
      Rails.logger.info "✅ 参加者保存成功: #{participant.nickname}"

      ActionCable.server.broadcast(
        "game_room_#{@game_room.id}",
        {
          type: 'participant_joined',
          participant:{
            id: participant.id,
            nickname: participant.nickname,
            is_ready: participant.is_ready
          },
          participants_count: @game_room.participants.count
        }
      )
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

    if request.patch?

      # ゲーム時間を秒→分に
      time_limit_in_minutes = params[:time_limit].to_i
      time_limit_in_seconds = time_limit_in_minutes * 60

      # ゲーム開始処理
      @game_room.update(status: 'playing', time_limit: time_limit_in_seconds, started_at: Time.current)
      
      # 準備完了している参加者がいるかチェック
      if @game_room.participants.where(is_ready: true).exists?
        word_kit = @game_room.word_kit 
        
        Rails.logger.debug "=== ブロードキャスト実行 ==="
        # 参加者には game_plays#show へのリダイレクトURLを送る
        ActionCable.server.broadcast(
        "game_channel_#{@game_room.id}", 
          {
            type: "game_start",
            message: "ゲームが始まりました",
            redirect_url: game_room_game_play_path(@game_room)
          }
        )
        Rails.logger.debug "=== ブロードキャスト完了 ==="
        
        # ホスト自身は start (GET) にリダイレクト
        redirect_to start_game_room_path(@game_room), status: :see_other
      else
        # 参加者がいない場合
        redirect_to game_room_path(@game_room), alert: '準備完了の参加者がいません'
      end
      
    elsif request.get?
      # ホストのゲーム画面表示
      @questions = @game_room.word_kit.word_cards
      # start.html.erb が表示される
    end
  end

  def waiting
    @game_room = GameRoom.find(params[:id])
  end

  def finish
    @game_room = GameRoom.find(params[:id])

    @game_room.update!(finished_at: Time.current)

    if @game_room.started_at.present?
      duration = @game_room.finished_at - @game_room.started_at
      minutes = (duration / 60).to_i
    else
      minutes = 0
    end

    @game_room.participants.each do |participant|
      if participant.user_id.present?
        user = User.find(participant.user_id)

        user.increment!(:total_score, participant.score.to_i)

        user.learning_logs.create!(
          score: participant.score.to_i,
          minutes: minutes
        )
      end
    end

    @game_room.destroy!
    redirect_to root_path, success: '学習記録を保存してゲームを終了しました'
  end

  private

  def game_room_params
    params.require(:game_room).permit(:time_limit, :status)
  end
end

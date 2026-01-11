class GamePlaysController < ApplicationController
  before_action :set_game_room
  before_action :set_participant, except: [:finish]
  before_action :authorize_host, only: [:finish]

  # ゲームプレイ画面の表示
  def show
    Rails.logger.info "=== GamePlay show 開始 ==="
    Rails.logger.info "participant: #{@participant.id}, is_host: #{@is_host}"
    
    # 参加者のみアクセス可能
    if @is_host
      redirect_to game_room_path(@game_room), alert: 'ホストはこの画面にアクセスできません'
      return
    end
    
    @word_kit = @game_room.word_kit
    @word_cards = @word_kit.word_cards
    @total_questions = @word_cards.count

    @questions = @word_cards.map do |card|
      {
        id: card.id,
        word: card.english_word,
        correct_answer: card.japanese_translation,
        incorrect_answers: []  # ← nil の場合は空配列
      }
    end
    
    @current_question = @questions.first

    Rails.logger.info "📊 問題データ: #{@questions.inspect}"
  end

  # ゲーム状態の更新
  def update
    # 必要に応じて実装
  end
  
  # 回答処理
  def answer
    @word_kit = @game_room.word_kit
    @questions = @word_kit.word_cards
    @current_question = @questions[session[:question_index]]
    
    # 正誤判定
    is_correct = params[:answer] == @current_question.correct_answer
    
    # スコア更新
    if is_correct
      @participant.increment!(:score)
    end
    
    # 次の問題へ
    session[:question_index] = (session[:question_index] || 0) + 1
    
    # 全問終了チェック
    if session[:question_index] >= @questions.count
      redirect_to result_game_room_game_play_path(@game_room)
    else
      redirect_to game_room_game_play_path(@game_room)
    end
  end
  
  # 結果表示
  def overall_result
    Rails.logger.info "=== overall_result 開始 ==="

    if @is_host
    # ホスト用: 全体結果を表示
      @participants = @game_room.participants.includes(:user, :guest).order(score: :desc)
      @total_questions = @game_room.word_kit.word_cards.count
      @top_players = @participants.order(score: :desc).limit(3)
      Rails.logger.info "ホスト用の全体結果表示"
      render :overall_result
    else
      # 参加者用: 個人結果にリダイレクト
      Rails.logger.info "参加者用: personal_result にリダイレクト"
      redirect_to personal_result_game_room_game_play_path(@game_room)
    end
  end

  def personal_result
    Rails.logger.info "=== personal_result 開始 ==="

    # @participant が存在しない場合
    unless @participant
      redirect_to root_path, alert: '参加者情報が見つかりません'
      return
    end
    
    # スコアと問題数を取得
    @score = @participant.score
    @total_questions = @game_room.word_kit.word_cards.count
    
    # 正解率を計算（オプション）
    @correct_rate = @total_questions > 0 ? (@score.to_f / @total_questions * 100).round(1) : 0
    
    Rails.logger.info "スコア: #{@score} / #{@total_questions}"
    Rails.logger.info "正解率: #{@correct_rate}%"
  end
    
  # ★ スコア更新処理（JavaScript から呼ばれる）
  def update_score
    Rails.logger.info "=== update_score 開始 ==="
    Rails.logger.info "受信したスコア: #{params[:score]}"
    
    if @participant.update(score: params[:score])
      Rails.logger.info "✅ スコア保存成功: #{params[:score]}点"
      render json: { 
        success: true, 
        score: @participant.score,
        message: 'スコアを保存しました'
      }
    else
      Rails.logger.error "❌ スコア保存失敗"
      render json: { 
        error: 'スコアの保存に失敗しました' 
      }, status: :unprocessable_entity
    end
  end
  
  # ★ ゲーム終了処理（JavaScript から呼ばれる）
  def finish
    Rails.logger.info "=== finish 開始 ==="
    Rails.logger.info "現在のステータス: #{@game_room.status}"
    
    if @game_room.playing?
      @game_room.update!(status: :finished)
      
      host_redirect_url = overall_result_game_room_game_play_path(@game_room)
      
      # ⭐️ メッセージを送信
      ActionCable.server.broadcast(
        "game_channel_#{@game_room.id}",
        {
          type: 'game_finished',
          message: 'ゲームが終了しました！',
        }
      )
      Rails.logger.info "✅ ゲーム終了成功"
      render json: { 
        success: true, 
        message: 'ゲームが終了しました',
        redirect_url: host_redirect_url
      }
    else
      Rails.logger.warn "⚠️ ゲームは既に終了しています"
      render json: { 
        success: false, 
        message: 'ゲームは既に終了しています' 
      }, status: :unprocessable_entity
    end
  end
  
  private
  
  # GameRoom を取得
  def set_game_room
    @game_room = GameRoom.find(params[:game_room_id])
    Rails.logger.debug "=== GameRoom 取得: #{@game_room.id} ==="
  rescue ActiveRecord::RecordNotFound
    Rails.logger.error "=== GameRoom が見つかりません ==="
    redirect_to root_path, alert: 'ゲームルームが見つかりません'
  end
  
  # Participant を取得
  def set_participant
    Rails.logger.debug "=== set_participant 開始 ==="
    Rails.logger.debug "current_user: #{current_user&.id}"
    Rails.logger.debug "host_user: #{@game_room.host_user&.id}"
    
    # ホストかどうかの判定
    @is_host = current_user && current_user == @game_room.host_user
    
    # ホストの場合は overall_result のみ許可
    if @is_host
      Rails.logger.debug "=== ホストがアクセス ==="
      
      # overall_result 以外はアクセス不可
      unless %w[overall_result finish].include?(action_name)
        redirect_to game_room_path(@game_room), alert: 'ホストはゲームに参加できません'
        return
      end
      
      @participant = nil
      return
    end
    
    # 参加者の処理
    if current_user
      @participant = @game_room.participants.find_by(user_id: current_user.id)
    elsif current_guest
      @participant = @game_room.participants.find_by(guest_id: current_guest.id)
    else
      respond_to do |format|
        format.html { redirect_to root_path, alert: '参加者情報が見つかりません' }
        format.json { render json: { error: '参加者情報が見つかりません' }, status: :unauthorized }
      end
      return
    end

    unless @participant
      respond_to do |format|
        format.html { redirect_to root_path, alert: 'このゲームに参加していません' }
        format.json { render json: { error: 'このゲームに参加していません' }, status: :forbidden }
      end
      return
    end
    
    Rails.logger.debug "=== Participant 取得成功: #{@participant.id} ==="
  end

  def authorize_host
    unless current_user && current_user == @game_room.host_user
      respond_to do |format|
        format.html { redirect_to root_path, alert: 'ホストのみがこの操作を行えます' }
        format.json { render json: { error: 'ホストのみがこの操作を行えます' }, status: :forbidden }
      end
    end
  end
end
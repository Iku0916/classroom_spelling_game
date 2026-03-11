# frozen_string_literal: true

class GamePlaysController < ApplicationController
  before_action :set_game_room
  before_action :set_participant, except: [:finish]
  before_action :authorize_host, only: [:finish]

  def show
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
        incorrect_answers: []
      }
    end

    @current_question = @questions.first
  end

  def update
  end

  def answer
    @word_kit = @game_room.word_kit
    @questions = @word_kit.word_cards
    @current_question = @questions[session[:question_index]]

    is_correct = params[:answer] == @current_question.correct_answer

    @participant.increment!(:score) if is_correct

    session[:question_index] = (session[:question_index] || 0) + 1

    if session[:question_index] >= @questions.count
      redirect_to result_game_room_game_play_path(@game_room)
    else
      redirect_to game_room_game_play_path(@game_room)
    end
  end

  def overall_result
    if @is_host
      @participants = @game_room.participants.includes(:user, :guest).order(score: :desc)
      @total_questions = @game_room.word_kit.word_cards.count
      @top_players = @participants.order(score: :desc).limit(3)
      render :overall_result
    else
      redirect_to personal_result_game_room_game_play_path(@game_room)
    end
  end

  def personal_result
    unless @participant
      redirect_to root_path, alert: '参加者情報が見つかりません'
      return
    end

    @score = @participant.score
    @total_questions = @game_room.word_kit.word_cards.count

    @correct_rate = @total_questions.positive? ? (@score.to_f / @total_questions * 100).round(1) : 0
  end

  def update_score
    new_score = params[:score].to_i

    if new_score > @participant.score
      @participant.update(score: new_score)
    end

    render json: { success: true, score: @participant.score }
  end

  def finish
    unless @game_room.playing?
      return render json: { success: false, message: 'ゲームは既に終了しています' }, status: :unprocessable_entity
    end

    @game_room.update!(
      status: :finished,
      finished_at: Time.current
    )

    minutes = if @game_room.started_at.present?
                ((@game_room.finished_at - @game_room.started_at) / 60).to_i
              else
                0
              end

    @game_room.participants.each do |participant|
      next unless participant.user_id.present?

      user = User.find(participant.user_id)
      user.increment!(:total_score, participant.score.to_i)
      user.learning_logs.create!(score: participant.score.to_i, minutes: minutes, word_kit_id: @game_room.word_kit_id)
    end

    host_redirect_url = overall_result_game_room_game_play_path(@game_room)

    ActionCable.server.broadcast(
      "game_channel_#{@game_room.id}",
      {
        type: 'game_finished',
        message: 'ゲームが終了しました！'
      }
    )
    render json: {
      success: true,
      message: 'ゲームが終了しました',
      redirect_url: host_redirect_url
    }
  end

  private

  def set_game_room
    @game_room = GameRoom.find(params[:game_room_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: 'ゲームルームが見つかりません'
  end

  def set_participant
    @is_host = current_user && current_user == @game_room.host_user

    if @is_host
      unless %w[overall_result finish].include?(action_name)
        redirect_to game_room_path(@game_room), alert: 'ホストはゲームに参加できません'
        return
      end

      @participant = nil
      return
    end

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
  end

  def authorize_host
    return if current_user && current_user == @game_room.host_user

    respond_to do |format|
      format.html { redirect_to root_path, alert: 'ホストのみがこの操作を行えます' }
      format.json { render json: { error: 'ホストのみがこの操作を行えます' }, status: :forbidden }
    end
  end
end

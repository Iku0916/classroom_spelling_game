# frozen_string_literal: true

class GamePlaysController < ApplicationController
  before_action :set_game_room
  before_action :set_participant, except: [:finish]
  before_action :authorize_host, only: [:finish]

  def show
    @questions = @game_room.word_cards.map(&:to_question)
    @total_questions = @questions.count
    @current_question = @questions.first
  end

  def update; end

  def answer
    redirect_path = @game_room.process_answer(@participant, params[:answer], session)
    redirect_to redirect_path
  end

  def overall_result
    if @is_host
      @participants = @game_room.ranking
      @total_questions = @game_room.word_kit.word_cards.count
      @top_players = @game_room.top_players(3)
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
    @correct_rate = @participant.correct_rate
  end

  def update_score
    new_score = params[:score].to_i

    @participant.update(score: new_score) if new_score > @participant.score

    render json: { success: true, score: @participant.score }
  end

  def finish
    return render json: { success: false, message: 'ゲームは既に終了しています' }, status: :unprocessable_entity unless @game_room.playing?

    @game_room.complete_game!
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

  def handle_host_access
    @is_host = (current_user == @game_room.host_user)
    return false unless @is_host

    unless %w[overall_result finish].include?(action_name)
      redirect_to game_room_path(@game_room), alert: 'ホストはこの画面にアクセスできません'
      return true
    end

    false
  end

  def set_participant
    @is_host = current_user == @game_room.host_user
    return if handle_host_access

    @participant = @game_room.find_participant(current_user, current_guest)
    render_unauthorized('このゲームに参加していません') unless @participant
  end

  def authorize_host
    return if current_user == @game_room.host_user

    respond_to do |format|
      format.html { redirect_to root_path, alert: 'ホストのみがこの操作を行えます' }
      format.json { render json: { error: 'ホストのみがこの操作を行えます' }, status: :forbidden }
    end
  end
end

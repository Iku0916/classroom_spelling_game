# frozen_string_literal: true

class SelfStudiesController < ApplicationController
  before_action :set_word_kit, only: %i[new play answer update result]

  def new; end

  def play
    @time_limit = calculate_time_limit(params[:time_limit_minutes])
    @questions = format_questions(@word_kit)
    @total_questions = @word_kit.word_cards.count
  end

  def answer
    cards = @word_kit.word_cards.to_a
    index = (session[:question_index] || 0) % cards.length

    update_session_score(cards[index])

    session[:question_index] = index + 1
    head :ok
  end

  def update
    log_data = learning_log_params
    save_learning_log(log_data)

    render json: { status: 'success' }, status: :ok
  rescue StandardError => e
    render json: { status: 'error', message: e.message }, status: :internal_server_error
  end

  def result
    @score = params[:score].to_i
    @total = @word_kit.word_cards.count
    @user = current_user
    reset_session_stats
  end

  private

  def set_word_kit
    @word_kit = WordKit.find_by!(uuid: params[:word_kit_uuid])
  rescue ActiveRecord::RecordNotFound
    redirect_to word_kits_path, alert: 'ゲームキットが見つかりませんでした'
  end

  def calculate_time_limit(minutes_param)
    minutes = minutes_param.to_f
    (minutes.positive? ? minutes : 1) * 60
  end

  def format_questions(word_kit)
    word_kit.word_cards.map do |word|
      { word: word.english_word, correct_answer: word.japanese_translation }
    end
  end

  def update_session_score(current_card)
    return unless params[:answer] == current_card.japanese_translation

    session[:current_score] = (session[:current_score] || 0) + 1
  end

  def save_learning_log(log_data)
    score = log_data[:score].to_i
    current_user.increment!(:total_score, score)
    current_user.learning_logs.create!(
      log_data.merge(word_kit_id: @word_kit.id)
    )
  end

  def reset_session_stats
    session[:current_score] = 0
    session[:question_index] = 0
  end

  def learning_log_params
    params.require(:learning_log).permit(:score, :minutes)
  end
end

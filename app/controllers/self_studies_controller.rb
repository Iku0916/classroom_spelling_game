class SelfStudiesController < ApplicationController
  def new
    @word_kit = WordKit.find(params[:word_kit_id])
  end

  def play
    @word_kit = WordKit.find_by(id: params[:word_kit_id])
    minutes = params[:time_limit_minutes].to_f
    @time_limit = (minutes > 0 ? minutes : 1) * 60

    @questions = @word_kit.word_cards.map do |word|
        {
          word: word.english_word,
          correct_answer: word.japanese_translation
        }
    end

    if @word_kit.nil?
      redirect_to word_kits_path, alert: "ゲームキットが見つかりませんでした"
      return
    end

    @word_cards = @word_kit.word_cards
    @total_questions = @word_cards.count
  end

  def answer
    @word_kit = WordKit.find(params[:word_kit_id])
    cards = @word_kit.word_cards.to_a

    index = session[:question_index] || 0
    index = index % cards.length
    current_card = cards[index]

    if params[:answer] == current_card.japanese_translation
      session[:current_score] = (session[:current_score] || 0) + 1
    end

    session[:question_index] = index + 1
    head :ok
  end

  def update
    @word_kit = WordKit.find(params[:word_kit_id])

    score = params[:score].to_i
    minutes = params[:minutes].to_f

    current_user.increment!(:total_score, score)
    current_user.learning_logs.create!(score: score, minutes: minutes)

    session[:current_score] = 0
    session[:question_index] = 0

    head :ok
  end



  def result
    @word_kit = WordKit.find(params[:word_kit_id])
    @score = params[:score].to_i
    @total = @word_kit.word_cards.count
    @user = current_user

    session[:current_score] = 0
    session[:question_index] = 0
  end
end

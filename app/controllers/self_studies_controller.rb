class SelfStudiesController < ApplicationController
  def show
    @word_kit = WordKit.find_by(id: params[:id])

    if @word_kit.nil?
      redirect_to word_kits_path, alert: "ゲームキットが見つかりませんでした"
      return
    end

    @word_cards = @word_kit.word_cards
    @total_questions = @word_cards.count
  end

  def answer
    @word_kit = WordKit.find_by(id: params[:id])
    @questions = @word_kit.word_cards
    
    index = session[:question_index] || 0
    @current_question = @questions[index]

  if params[:answer] == @current_question.correct_answer
    session[:current_score] = (session[:current_score] || 0) + 1
  end

    session[:question_index] = ((session[:question_index] || 0) + 1) % @questions.count
  end

  def update
    personal_score = session[:current_score] || 0

    current_user.increment!(:total_score, personal_score)

    session[:current_score] = 0
    session[:question_index] = 0

    redirect_to result_path(score: personal_score), notice: "お疲れ様！"
  end
end

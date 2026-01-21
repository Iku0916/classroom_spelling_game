class WordKitsController < ApplicationController
  before_action :require_login

  def index
    @word_kits = current_user.word_kits.order(created_at: :desc)
  end

  def new
    @word_kit = WordKit.new
    @word_kit.word_cards.build
  end

  def create
    @word_kit = current_user.word_kits.build(word_kit_params)

    if @word_kit.save
        redirect_to word_kits_path, notice: "キットを作成しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @word_kit = current_user.word_kits.find(params[:id])

    if @word_kit.destroy
      redirect_to word_kits_path, notice: "ゲームキットを削除しました"
    else
      redirect_to word_kits_path
    end
  end

  def show
    @word_kit = current_user.word_kits.find(params[:id])
    @questions = @word_kit.word_cards
  end

  def play
    @game_room = GameRoom.find(params[:game_room_id])
    @word_kit = @game_room.word_kit
    @questions = @word_kit.word_cards

    Rails.logger.debug "=== Game Room Debug ==="
    Rails.logger.debug "Questions count: #{@questions.count}"
    Rails.logger.debug "Questions: #{@questions.inspect}"

    session[:question_index] ||= 0
    @current_index = session[:question_index]
    @current_question = @questions[@current_index]
  end

  def edit
     @word_kit = current_user.word_kits.find(params[:id])
  end

def update
    @word_kit = current_user.word_kits.find(params[:id])

    @word_kit.assign_attributes(word_kit_params)

    has_changes = @word_kit.changed?

    if has_changes
      if @word_kit.save
        redirect_to word_kits_path, notice: '更新しました'
      else
        render :edit, status: :unprocessable_entity
      end
    else
      redirect_to word_kits_path, notice: '変更はありませんでした'
    end
  end

  private

  def word_kit_params
    params.require(:word_kit).permit(
      :name,
      word_cards_attributes: [:id, :english_word, :japanese_translation, :_destroy]
    )
  end
end

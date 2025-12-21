class WordCardsController < ApplicationController
  before_action :require_login
  before_action :set_word_kit

  def index
    @word_cards = @word_kit.word_cards
  end

  def new
    @word_card = WordCard.new
  end

  def create
    @word_card = @word_kit.word_cards.new(word_card_params)

    if params[:finished]
      redirect_to word_kits_path, notice: "ゲームキットの作成ができました！"
    else
      if @word_card.save
         redirect_to new_word_kit_word_card_path(@word_kit)
      else
        render :new
      end
    end
  end

  def edit
    @word_card = WordCard.find(params[:id])
    @word_kit = @word_card.word_kit
  end

  def update
    @word_card = WordCard.find(params[:id])
    @word_kit = @word_card.word_kit

    if @word_card.update(word_card_params)
      redirect_to edit_word_kit_path(@word_kit)
    else
      render :edit
    end
  end

  def destroy
    word_card = WordCard.find(params[:id])
    word_kit = word_card.word_kit
    word_card.destroy
    redirect_to edit_word_kit_path(word_kit)
  end

  private

  def set_word_kit
    @word_kit = WordKit.find(params[:word_kit_id])
  end

  def word_card_params
    params.require(:word_card).permit(:english_word, :japanese_translation)
  end
end
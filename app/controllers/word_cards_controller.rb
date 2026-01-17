class WordCardsController < ApplicationController
  before_action :require_login
  before_action :set_word_kit

  def index
    @word_cards = @word_kit.word_cards
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
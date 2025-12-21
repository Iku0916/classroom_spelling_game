class WordKitsController < ApplicationController
  before_action :require_login

  def index
    @word_kits = WordKit.all
  end

  def new
    @word_kit = WordKit.new
  end

  def create
    @word_kit = current_user.word_kits.build(word_kit_params)

    if @word_kit.save
        redirect_to new_word_kit_word_card_path(@word_kit), notice: "キットを作成しました"
    else
      render :new
    end
  end

  def destroy
    @word_kit = WordKit.find(params[:id])

    if @word_kit.destroy
      redirect_to word_kits_path, notice: "ゲームキットを削除しました"
    else
      redirect_to word_kits_path
    end
  end

  def show
    @word_kit = WordKit.find(params[:id])
    @word_cards = @word_kit.word_cards 
  end

  def edit
     @word_kit = WordKit.find(params[:id])
     @word_cards = @word_kit.word_cards
  end

  def update
    @word_kit = WordKit.find(params[:id])
    if @word_kit.update(word_kit_params)
      redirect_to word_kit_path(@word_kit)
    else
      render :edit
    end
  end

  private

  def word_kit_params
    params.require(:word_kit).permit(:name)
  end
end

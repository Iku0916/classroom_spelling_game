class WordKitsController < ApplicationController

  def new
    @word_kit = WordKit.new
  end

  def create
    @word_kit = current_user.word_kits.build(word_kit_params)

    if @word_kit.save
      redirect_to word_kit_path(@word_kit), notice: "キットを作成しました"
    else
      render :new
    end
  end

  private

  def word_kit_params
    params.require(:word_kit).permit(:name)
  end
end

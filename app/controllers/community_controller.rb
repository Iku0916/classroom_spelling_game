class CommunityController < ApplicationController
  def index
    @public_word_kits = WordKit.where(visibility: "public_kit")
  end

  def show
    @word_kit = WordKit.find(params[:id])
  end
end

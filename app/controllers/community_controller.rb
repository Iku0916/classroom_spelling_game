class CommunityController < ApplicationController
  def index
    @public_word_kits = WordKit.where(visibility: "public_kit")

    if params[:keyword].present?
      @public_word_kits = @public_word_kits.left_outer_joins(:tags).where(
        "word_kits.name LIKE :q OR tags.name LIKE :q",
        q: "%#{params[:keyword]}%"
      ).distinct
    end
  end

  def show
    @word_kit = WordKit.find(params[:id])
  end
end

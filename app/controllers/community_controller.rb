class CommunityController < ApplicationController
  def index
    @public_word_kits = WordKit.where(visibility: "public_kit").left_outer_joins(:tags)

    if params[:keyword].present?
      keywords = params[:keyword].split(/[[:space:]]+/)
      
      keywords.each do |word|
        @public_word_kits = @public_word_kits.where(
          "word_kits.name LIKE :q OR tags.name LIKE :q",
          q: "%#{word}%"
        )
      end
    end

    @public_word_kits = @public_word_kits.distinct.order(created_at: :desc)
  end

  def show
    @word_kit = WordKit.find(params[:id])
  end
end

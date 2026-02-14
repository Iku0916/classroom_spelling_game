class CommunityController < ApplicationController
  def index
    @public_word_kits = WordKit.where(visibility: "public_kit")
  end
end

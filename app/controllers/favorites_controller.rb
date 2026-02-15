class FavoritesController < ApplicationController
  before_action :set_word_kit

  def create
    favorite = current_user.favorites.find_or_initialize_by(word_kit: @word_kit)
    if favorite.new_record?
      favorite.save!
    end

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back(fallback_location: root_path) }
    end
  end

  def destroy
    favorite = current_user.favorites.find_by(word_kit: @word_kit)
    
    if favorite
      favorite.destroy
    end

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back fallback_location: root_path }
    end
  end


  private

  def set_word_kit
    @word_kit = WordKit.find(params[:word_kit_id])
  end
end
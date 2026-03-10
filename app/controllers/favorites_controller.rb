# frozen_string_literal: true

class FavoritesController < ApplicationController
  before_action :set_word_kit, only: %i[create destroy]

  def index
    @favorite_word_kits = current_user
                          .favorites
                          .includes(:word_kit)
                          .map(&:word_kit)
  end

  def create
    favorite = current_user.favorites.find_or_initialize_by(word_kit: @word_kit)
    favorite.save! if favorite.new_record?

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back(fallback_location: root_path) }
    end
  end

  def destroy
    favorite = current_user.favorites.find_by(word_kit: @word_kit)

    favorite&.destroy

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

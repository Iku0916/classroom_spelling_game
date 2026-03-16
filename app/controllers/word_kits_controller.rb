# frozen_string_literal: true

class WordKitsController < ApplicationController
  before_action :require_login
  before_action :set_word_kit, only: %i[destroy show edit update]

  def index
    @word_kits = current_user.word_kits.left_outer_joins(:tags)

    if params[:keyword].present?
      keywords = params[:keyword].split(/[[:space:]]+/)

      keywords.each do |word,|
        @word_kits = @word_kits.where(
          'word_kits.name LIKE :q OR tags.name LIKE :q',
          q: "%#{word}%"
        )
      end
    end

    @word_kits = @word_kits.distinct.order(created_at: :desc)
  end

  def new
    @word_kit = WordKit.new
    @word_kit.word_cards.build
  end

  def create
    @word_kit = current_user.word_kits.build(word_kit_params)

    if @word_kit.save
      redirect_to word_kits_path, notice: 'キットを作成しました'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @word_kit = current_user.word_kits.find(params[:id])

    if @word_kit.destroy
      redirect_to word_kits_path, notice: 'ゲームキットを削除しました'
    else
      redirect_to word_kits_path
    end
  end

  def show
    @word_kit = current_user.word_kits.find(params[:id])
    @questions = @word_kit.word_cards
  end

  def play
    @game_room = GameRoom.find(params[:game_room_id])
    @word_kit = @game_room.word_kit
    @questions = @word_kit.word_cards
    session[:question_index] ||= 0
    @current_index = session[:question_index]
    @current_question = @questions[@current_index]
  end

  def edit
    @word_kit = current_user.word_kits.find(params[:id])
  end

  def update
    tags_modified = @word_kit.tags_changed?(params[:word_kit][:tag_list])
    @word_kit.assign_attributes(word_kit_params)

    return redirect_to word_kits_path, notice: '変更はありませんでした' unless tags_modified || @word_kit.changed_with_contents?

    if @word_kit.save
      redirect_to word_kits_path, notice: '更新しました'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def copy
    original = WordKit.find(params[:id])
    @copied_kit = original.duplicate_for(current_user)

    if @copied_kit.save
      redirect_to word_kit_path(@copied_kit), notice: '複製しました！'
    else
      redirect_to word_kits_path, alert: '複製に失敗しました'
    end
  end

  private

  def set_word_kit
    @word_kit = current_user.word_kits.find(params[:id])
  end

  def word_kit_params
    params.require(:word_kit).permit(
      :name,
      :visibility,
      :tag_list,
      word_cards_attributes: %i[id english_word japanese_translation _destroy]
    )
  end
end

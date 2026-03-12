# frozen_string_literal: true

class User < ApplicationRecord
  authenticates_with_sorcery!

  has_many :word_kits, dependent: :destroy
  has_many :game_rooms, dependent: :destroy
  has_many :participants, dependent: :destroy
  has_many :learning_logs, dependent: :destroy
  has_many :favorites, dependent: :destroy
  has_many :favorite_word_kits, through: :favorites, source: :word_kit
  has_many :authentications, dependent: :destroy

  accepts_nested_attributes_for :authentications

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true

  with_options if: :password_required? do |v|
    v.validates :password, length: { minimum: 8 }
    v.validates :password, confirmation: true
    v.validates :password_confirmation, presence: true
  end

  def total_score
    self[:total_score] || learning_logs.sum(:score)
  end

  def total_minutes
    learning_logs.sum(:minutes)
  end

  def total_hours_and_minutes
    h = total_minutes / 60
    m = total_minutes % 60
    { hours: h, minutes: m }
  end

  def record_learning_result(score, minutes, word_kit_id)
    increment!(:total_score, score.to_i)
    learning_logs.create!(
      score: score.to_i,
      minutes: minutes,
      word_kit_id: word_kit_id
    )
  end

  private

  def password_required?
    (new_record? || changes[:crypted_password]) && !@external_redirect
  end
end

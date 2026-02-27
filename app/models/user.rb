class User < ApplicationRecord
  authenticates_with_sorcery!

  has_many :word_kits
  has_many :game_rooms
  has_many :participants
  has_many :learning_logs, dependent: :destroy

  has_many :favorites
  has_many :favorite_word_kits, through: :favorites, source: :word_kit

  has_many :authentications, dependent: :destroy
  accepts_nested_attributes_for :authentications

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

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :password, length: { minimum: 8 }, if: -> { new_record? || changes[:crypted_password] }, unless: -> { @external_redirect }
  validates :password, confirmation: true, if: -> { new_record? || changes[:crypted_password] }, unless: -> { @external_redirect }
  validates :password_confirmation, presence: true, if: -> { new_record? || changes[:crypted_password] }, unless: -> { @external_redirect }
end

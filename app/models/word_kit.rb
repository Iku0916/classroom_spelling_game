class WordKit < ApplicationRecord
  has_many :word_cards, dependent: :destroy
  accepts_nested_attributes_for :word_cards, allow_destroy: true, reject_if: :all_blank
  has_many :game_rooms, dependent: :destroy
  belongs_to :user

  enum visibility: { private_kit: 0, public_kit: 1 }

  validates :name, presence: { message: "ゲームキット名を入力してください" }
end
class WordKit < ApplicationRecord
  has_many :word_cards, dependent: :destroy
  accepts_nested_attributes_for :word_cards, allow_destroy: true, reject_if: :all_blank
  has_many :game_rooms, dependent: :destroy
  belongs_to :user

  validates :name, presence: true
end
class WordKit < ApplicationRecord
  has_many :word_cards,  dependent: :destroy
  has_many :game_rooms
  belongs_to :user

  validates :name, presence: true
end
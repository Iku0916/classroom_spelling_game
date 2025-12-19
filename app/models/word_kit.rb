class WordKit < ApplicationRecord
  has_many :word_cards
  belongs_to :user

  validates :name, presence: true
end
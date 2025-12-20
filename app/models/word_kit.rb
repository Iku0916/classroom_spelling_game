class WordKit < ApplicationRecord
  has_many :word_cards,  dependent: :destroy
  belongs_to :user

  validates :name, presence: true
end
class WordCard < ApplicationRecord
  belongs_to :word_kit

  validates :english_word, presence: true
  validates :japanese_translation, presence: true

  def pair
    {
      english: english_word,
      japanese: japanese_translation
    }
  end
end
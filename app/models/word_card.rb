# frozen_string_literal: true

class WordCard < ApplicationRecord
  belongs_to :word_kit

  validates :english_word, presence: { message: '英語を入力してください' }
  validates :japanese_translation, presence: { message: '日本語を入力してください' }

  def pair
    {
      english: english_word,
      japanese: japanese_translation
    }
  end

  def to_question
    { id: id, word: english_word, correct_answer: japanese_translation, incorrect_answers: [] }
  end
end

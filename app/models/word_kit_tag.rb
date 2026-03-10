# frozen_string_literal: true

class WordKitTag < ApplicationRecord
  belongs_to :word_kit
  belongs_to :tag
end

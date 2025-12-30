class GameRoom < ApplicationRecord
  has_many :participants
  belongs_to :user
  belongs_to :word_kit

  validates :time_limit, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 60 }
  validates :status, presence: true
  validates :game_code, uniqueness: true

  enum status: {waiting: 0, playing: 1, finished: 2}
end
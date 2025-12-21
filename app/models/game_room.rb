class GameRoom < ApplicationRecord
  has_many :participants

  validates :time_limit, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 60 }
  validates :status, presence: true
end
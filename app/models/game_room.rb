class GameRoom < ApplicationRecord
  has_many :participants, dependent: :destroy
  has_many :guests, through: :participants
  belongs_to :word_kit
  belongs_to :host_user, class_name: 'User', foreign_key: 'host_user_id'

  validates :time_limit, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 60, less_than_or_equal_to: 3600 }, allow_nil: true
  validates :status, presence: true
  validates :game_code, uniqueness: true

  enum status: {waiting: 0, playing: 1, finished: 2}
end
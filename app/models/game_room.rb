# frozen_string_literal: true

class GameRoom < ApplicationRecord
  has_many :participants, dependent: :destroy
  has_many :guests, through: :participants
  belongs_to :word_kit
  belongs_to :host_user, class_name: 'User', foreign_key: 'host_user_id'

  validates :time_limit, presence: true,
                         numericality: { only_integer: true, greater_than_or_equal_to: 60, less_than_or_equal_to: 3600 }, allow_nil: true
  validates :status, presence: true
  validates :game_code, uniqueness: true

  enum status: { waiting: 0, playing: 1, finished: 2 }

  def find_participant(user, guest)
    return participants.find_by(user_id: user.id) if user

    participants.find_by(guest_id: guest.id) if guest
  end

  def ranking
    participants.includes(:user, :guest).order(score: :desc)
  end

  def top_players(limit = 3)
    ranking.limit(limit)
  end

  def word_cards
    word_kit.word_cards
  end

  def complete_game!
    update!(status: :finished, finished_at: Time.current)

    minutes = ((finished_at - (started_at || finished_at)) / 60).to_i

    participants.each do |participant|
      participant.user&.record_learning_result(participant.score, minutes, word_kit_id)
    end
  end

  def process_answer(participant, user_answer, session)
    index = session[:question_index] || 0
    question = word_cards[index]

    participant.submit_answer(question.correct_answer, user_answer)
    session[:question_index] = index + 1

    next_step_url(session[:question_index], word_cards.count, self)
  end
end

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

  def self.build_with_host(user, word_kit_id)
    new(
      host_user: user,
      game_code: SecureRandom.random_number(10**6).to_s.rjust(6, '0'),
      status: :waiting,
      time_limit: 300,
      word_kit_id: word_kit_id
    )
  end

  def broadcast_participant_joined(participant)
    ActionCable.server.broadcast(
      "game_room_#{id}",
      {
        type: 'participant_joined',
        participant: { id: participant.id, nickname: participant.nickname, is_ready: participant.is_ready },
        participants_count: participants.count
      }
    )
  end

  def start_game!(minutes)
    seconds = minutes.to_i * 60
    update!(status: 'playing', time_limit: seconds, started_at: Time.current)

    broadcast_game_start
  end

  def ready_participants?
    participants.where(is_ready: true).exists?
  end

  def broadcast_game_start
    ActionCable.server.broadcast(
      "game_channel_#{id}",
      {
        type: 'game_start',
        message: 'ゲームが始まりました',
        redirect_url: Rails.application.routes.url_helpers.game_room_game_play_path(self)
      }
    )
  end

  def finish_game!
    return unless playing?

    update!(status: :finished, finished_at: Time.current)

    process_results
    broadcast_finish
  end

  private

  def process_results
    minutes = ((finished_at - (started_at || finished_at)) / 60).to_i

    participants.each do |p|
      next unless p.user_id.present?

      p.user.increment!(:total_score, p.score.to_i)
      p.user.learning_logs.create!(score: p.score.to_i, minutes: minutes)
    end
  end

  def broadcast_finish
    ActionCable.server.broadcast(
      "game_channel_#{id}",
      { type: 'game_finished', message: 'ゲームが終了しました！' }
    )
  end
end

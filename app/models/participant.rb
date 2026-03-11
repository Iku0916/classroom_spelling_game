# frozen_string_literal: true

class Participant < ApplicationRecord
  belongs_to :guest, optional: true
  belongs_to :user, optional: true
  belongs_to :game_room

  validates :nickname, presence: true
  validate :either_user_or_guest_present

  before_validation :set_default_nuckname, on: :create

  def player
    user || guest
  end

  def player_type
    user.present? ? 'User' : 'Guest'
  end

  def host?
    user_id.present? && game_room.host_user_id == user_id
  end

  def submit_answer(correct_answer, user_answer)
    is_correct = (user_answer == correct_answer)
    increment!(:score) if is_correct
    is_correct
  end

  def correct_rate
    total = game_room.word_kit.word_cards.count
    return 0 if total.zero?

    ((score.to_f / total) * 100).round(1)
  end

  private

  def either_user_or_guest_present
    if user.blank? && guest.blank?
      errors.add(:base, 'UserまたはGuestのいずれかが必要です')
    elsif user.present? && guest.present?
      errors.add(:base, 'UserとGuestの両方を指定することはできません')
    end
  end

  def set_default_nuckname
    return if nickname.present?

    self.nickname = if user
                      user.name || "プレイヤー#{user.id}"
                    elsif guest
                      "ゲスト#{guest.id}"
                    else
                      '名無しさん'
                    end
  end
end

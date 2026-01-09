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
                      "名無しさん"
                   end
    end
  end

class Participant < ApplicationRecord
  belongs_to :guest, optional: true
  belongs_to :user, optional: true
  belongs_to :game_room

  validates :nickname, presence: true
  validate :either_user_or_guest_present

  def player
    user || guest
  end
  
  def player_type
    user.present? ? 'User' : 'Guest'
  end
  
  private
  
  def either_user_or_guest_present
    if user.blank? && guest.blank?
      errors.add(:base, 'UserまたはGuestのいずれかが必要です')
    elsif user.present? && guest.present?
      errors.add(:base, 'UserとGuestの両方を指定することはできません')
    end
  end
end

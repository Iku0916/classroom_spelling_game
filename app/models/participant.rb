class Participant < ApplicationRecord
  belongs_to :guest, optional: true
  belongs_to :game_room
  belongs_to :user, optional: true

  validates :nickname, presence: true
end

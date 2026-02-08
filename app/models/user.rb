class User < ApplicationRecord
  authenticates_with_sorcery!

  has_many :word_kits
  has_many :game_rooms
  has_many :participants
    has_many :learning_logs, dependent: :destroy

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :password, length: { minimum: 8 }, if: -> { new_record? || changes[:crypted_password] }
end

class Guest < ApplicationRecord
  validates :session_token, uniqueness: true, presence: true

  has_many :participants, dependent: :destroy
  has_many :game_rooms, through: :participants


  before_validation :generate_session_token, on: :create
  
  private
  
  def generate_session_token
    self.session_token ||= SecureRandom.urlsafe_base64
  end
end
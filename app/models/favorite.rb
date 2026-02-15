class Favorite < ApplicationRecord
  belongs_to :user
  belongs_to :word_kit

  validates :user_id, uniqueness: { scope: :word_kit_id }
end

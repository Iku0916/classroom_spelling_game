class Tag < ApplicationRecord
  has_many :word_kit_tags, dependent: :destroy
  has_many :word_kits, through: :word_kit_tags

  validates :name, presence: true, uniqueness: true
end

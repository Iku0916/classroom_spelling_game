class WordKit < ApplicationRecord
  has_many :word_cards, dependent: :destroy
  accepts_nested_attributes_for :word_cards, allow_destroy: true, reject_if: :all_blank
  has_many :game_rooms, dependent: :destroy
  belongs_to :user

  has_many :favorites, dependent: :destroy
  has_many :favorited_by_users, through: :favorites, source: :user
  has_many :word_kit_tags, dependent: :destroy
  has_many :tags, through: :word_kit_tags

  enum visibility: { private_kit: 0, public_kit: 1 }

  validates :name, presence: { message: "ゲームキット名を入力してください" }

  def tag_list=(names)
    self.tags = names.split(/[、,]/).map(&:strip).uniq.reject(&:empty?).map do |name|
      Tag.find_or_create_by(name: name)
    end

    self.updated_at = Time.current
  end

  def tag_list
    tags.pluck(:name).join(', ')
  end
end
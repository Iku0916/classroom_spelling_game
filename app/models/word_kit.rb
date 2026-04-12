# frozen_string_literal: true

class WordKit < ApplicationRecord
  has_many :word_cards, dependent: :destroy
  accepts_nested_attributes_for :word_cards, allow_destroy: true, reject_if: :all_blank
  has_many :game_rooms, dependent: :destroy
  belongs_to :user

  has_many :favorites, dependent: :destroy
  has_many :favorited_by_users, through: :favorites, source: :user
  has_many :word_kit_tags, dependent: :destroy
  has_many :tags, through: :word_kit_tags
  has_many :learning_logs, dependent: :nullify

  enum visibility: { private_kit: 0, public_kit: 1 }

  validates :name, presence: { message: 'ゲームキット名を入力してください' }

  def tag_list=(names)
    self.tags = names.split(/[、,]/).map(&:strip).uniq.reject(&:empty?).map do |name|
      Tag.find_or_create_by(name: name)
    end
  end

  def tag_list
    tags.pluck(:name).join(', ')
  end

  def duplicate_for(user)
    new_kit = dup
    new_kit.assign_attributes(
      name: "#{name} copy",
      visibility: 'private_kit',
      user: user,
      uuid: nil
    )

    word_cards.each do |card|
      new_kit.word_cards.build(
        english_word: card.english_word,
        japanese_translation: card.japanese_translation
      )
    end

    new_kit.tags = tags

    new_kit
  end

  def changed_with_contents?
    return true if changed?

    return true if word_cards.any? { |c| c.new_record? || c.changed? || c.marked_for_destruction? }

    false
  end

  def tags_changed?(new_tag_string)
    current_tags = tags.pluck(:name).sort
    new_tags = new_tag_string.to_s.split(/[、,]/).map(&:strip).reject(&:empty?).uniq.sort

    current_tags != new_tags
  end

  def to_param
    uuid
  end
end

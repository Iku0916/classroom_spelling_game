# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Tag, type: :model do
  describe '関連付け' do
    it 'WordKitが削除されたら中間テーブルのデータも削除されること' do
      user = User.create(name: 'テスト', email: 't@example.com', password: 'password', password_confirmation: 'password')
      kit = WordKit.create(name: 'キット', user: user)
      tag = Tag.create(name: 'テストタグ')
      WordKitTag.create(word_kit: kit, tag: tag)

      expect { kit.destroy }.to change(WordKitTag, :count).by(-1)
    end
  end
end

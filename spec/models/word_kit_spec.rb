require 'rails_helper'

RSpec.describe WordKit, type: :model do
  let(:user) { User.create(name: 'イクちゃん', email: 'test@example.com', password: 'password', password_confirmation: 'password') }
  let(:word_kit) { WordKit.create(name: 'テスト用キット', user: user) }

  describe 'バリデーション' do
    it '名前があれば有効であること' do
      expect(word_kit).to be_valid
    end

    it '名前が空だと無効であること' do
      word_kit.name = nil
      word_kit.valid?
      expect(word_kit.errors[:name]).to include('ゲームキット名を入力してください')
    end
  end

  describe '関連付けと依存関係' do
    it 'WordKitを削除するとレコードが減ること' do
      kit = WordKit.create(name: '消えるキット', user: user)
      expect { kit.destroy }.to change(WordKit, :count).by(-1)
    end
    
    it 'WordKitに紐付くWordCardも一緒に削除されること' do
      kit = WordKit.create(name: 'カード付きキット', user: user)
      kit.word_cards.create(english_word: 'test', japanese_translation: 'テスト')
      
      expect { kit.destroy }.to change(WordCard, :count).by(-1)
    end
  end

  describe '#duplicate_for' do
    it '新しいキットを作成し、名前がコピーされ、非公開になること' do
      word_kit.word_cards.create(english_word: 'apple', japanese_translation: 'りんご')

      new_kit = word_kit.duplicate_for(user)
      new_kit.save!

      expect(new_kit.name).to eq('テスト用キット copy')
      expect(new_kit.visibility).to eq('private_kit')
      expect(new_kit.word_cards.count).to eq(1)
    end
  end

  describe 'タグ機能' do
    let(:user) { User.create(name: 'イクちゃん', email: 'test@example.com', password: 'password', password_confirmation: 'password') }
    let(:word_kit) { WordKit.create(name: 'タグテスト', user: user) }

    it 'tag_list= でカンマ区切りのタグを保存できること' do
      word_kit.tag_list = 'Ruby, Rails, RSpec'
      word_kit.save
      
      expect(word_kit.tags.pluck(:name)).to match_array(['Ruby', 'Rails', 'RSpec'])
    end

    it 'tag_list でタグ名がカンマ区切りで取得できること' do
      word_kit.tags.create(name: 'Ruby')
      word_kit.tags.create(name: 'Rails')
      
      expect(word_kit.tag_list).to eq('Ruby, Rails')
    end
  end

  describe '#changed_with_contents?' do
    it '何も変更していないときは false を返すこと' do
      expect(word_kit.changed_with_contents?).to be false
    end

    it '名前を変更したときは true を返すこと' do
      word_kit.name = '名前変更'
      expect(word_kit.changed_with_contents?).to be true
    end

    it '新しい単語カードを追加したときは true を返すこと' do
      word_kit.word_cards.build(english_word: 'cat', japanese_translation: '猫')
      expect(word_kit.changed_with_contents?).to be true
    end

    it '登録済みの単語カードを更新したときは true を返すこと' do
      card = word_kit.word_cards.create!(english_word: 'dog', japanese_translation: '犬')
      card.english_word = 'puppy'
      expect(word_kit.changed_with_contents?).to be true
    end
  end
end
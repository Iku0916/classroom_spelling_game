require 'rails_helper'

RSpec.describe 'WordKits', type: :request do
  let(:user) { User.create!(name: 'イクちゃん', email: 'test@example.com', password: 'password', password_confirmation: 'password') }

  before do
    post login_path, params: { email: user.email, password: 'password' }
  end

  describe 'POST #create' do
    it '単語カードを含めてキットが正常に作成されること' do
      params = {
        word_kit: {
          name: 'テストキット',
          visibility: 'private_kit',
          tag_list: 'テスト, 初心者',
          word_cards_attributes: {
            '0' => { english_word: 'apple', japanese_translation: 'りんご' },
            '1' => { english_word: 'banana', japanese_translation: 'バナナ' }
          }
        }
      }

      expect {
        post word_kits_path, params: params
      }.to change(WordKit, :count).by(1)
       .and change(WordCard, :count).by(2)

      expect(response).to redirect_to(word_kits_path)
    end
  end

  describe 'PATCH #update' do
    let!(:word_kit) { WordKit.create!(name: '古い名前', user: user) }
    let!(:word_card) { word_kit.word_cards.create!(english_word: 'apple', japanese_translation: 'りんご') }

    it 'キット名、タグ、単語の更新と削除が正常に行われること' do
      params = {
        word_kit: {
          name: '新しい名前',
          tag_list: '新タグ1, 新タグ2',
          word_cards_attributes: {
            '0' => { 
              id: word_card.id, 
              english_word: 'apple', 
              japanese_translation: 'りんご', 
              _destroy: '1'
            }
          }
        }
      }

      patch word_kit_path(word_kit), params: params

      expect(word_kit.reload.name).to eq('新しい名前')

      expect(word_kit.tags.count).to eq(2)

      expect(WordCard.count).to eq(0)

      expect(flash[:notice]).to eq('更新しました')
      expect(response).to redirect_to(word_kits_path)
    end

    it '変更がない場合は「変更はありませんでした」とメッセージが表示されること' do
      params = {
        word_kit: {
          name: word_kit.name
        }
      }

      patch word_kit_path(word_kit), params: params

      expect(flash[:notice]).to eq('変更はありませんでした')
      expect(response).to redirect_to(word_kits_path)
    end
  end

  describe 'アクセス制御' do
    let(:me) { User.create!(name: '自分', email: 'me@example.com', password: 'password', password_confirmation: 'password') }
    let(:other_user) { User.create!(name: '他人', email: 'other@example.com', password: 'password', password_confirmation: 'password') }
    let(:private_kit) { other_user.word_kits.create!(name: 'ひみつ', visibility: 'private_kit') }

    # 1. ログインしていない場合
    it '未ログイン状態で他人のキットにアクセスすると、一覧画面へリダイレクトされること' do
      get word_kit_path(private_kit)
      
      expect(response).to redirect_to(word_kits_path)
    end

    it 'ログインしていても他人のキットにはアクセスできず、一覧へ戻されること' do
      post login_path, params: { email: me.email, password: 'password' }

      get word_kit_path(private_kit)

      expect(response).to redirect_to(word_kits_path)
    end
  end
end
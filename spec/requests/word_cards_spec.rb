# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'WordCards', type: :request do
  let(:user) { User.create!(name: 'イクちゃん', email: 'test@example.com', password: 'password', password_confirmation: 'password') }
  let(:word_kit) { WordKit.create!(name: 'テストキット', user: user) }
  let(:word_card) { word_kit.word_cards.create!(english_word: 'apple', japanese_translation: 'りんご') }

  before do
    post login_path, params: { email: user.email, password: 'password' }
  end

  describe 'GET #edit' do
    it '200 OKを返すこと' do
      get edit_word_kit_word_card_path(word_kit, word_card)
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'PATCH #update' do
    context '有効なパラメータのとき' do
      it '単語カードが更新されること' do
        patch word_kit_word_card_path(word_kit, word_card),
              params: { word_card: { english_word: 'orange', japanese_translation: 'オレンジ' } }
        expect(word_card.reload.english_word).to eq('orange')
      end

      it 'edit_word_kit_pathにリダイレクトされること' do
        patch word_kit_word_card_path(word_kit, word_card),
              params: { word_card: { english_word: 'orange', japanese_translation: 'オレンジ' } }
        expect(response).to redirect_to(edit_word_kit_path(word_kit))
      end
    end

    context '無効なパラメータのとき' do
      it '単語カードが更新されないこと' do
        patch word_kit_word_card_path(word_kit, word_card),
              params: { word_card: { english_word: '', japanese_translation: '' } }
        expect(word_card.reload.english_word).to eq('apple')
      end

      it 'editテンプレートを再表示すること' do
        patch word_kit_word_card_path(word_kit, word_card),
              params: { word_card: { english_word: '', japanese_translation: '' } }
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe 'DELETE #destroy' do
    it '単語カードが削除されること' do
      word_card
      expect do
        delete word_kit_word_card_path(word_kit, word_card)
      end.to change(WordCard, :count).by(-1)
    end

    it 'edit_word_kit_pathにリダイレクトされること' do
      delete word_kit_word_card_path(word_kit, word_card)
      expect(response).to redirect_to(edit_word_kit_path(word_kit))
    end
  end

  describe '未ログイン時のアクセス制御' do
    before { delete logout_path }

    it 'indexにアクセスするとログインページにリダイレクトされること' do
      get word_kit_word_cards_path(word_kit)
      expect(response).to redirect_to(login_path)
    end
  end
end

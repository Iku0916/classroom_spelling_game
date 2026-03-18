require 'rails_helper'

RSpec.describe 'お気に入り', type: :request do
  let(:user) do
    User.create!(
      name: 'イクちゃん',
      email: 'test@example.com',
      password: 'password',
      password_confirmation: 'password'
    )
  end

  let(:other_user) do
    User.create!(
      name: '他ユーザー',
      email: 'other@example.com',
      password: 'password',
      password_confirmation: 'password'
    )
  end

  let(:word_kit) { WordKit.create!(name: 'テストキット', user: other_user, visibility: 'public_kit') }
  let(:word_kit2) { WordKit.create!(name: '英語キット', user: other_user, visibility: 'public_kit') }

  before { post login_path, params: { email: user.email, password: 'password' } }

  describe 'お気に入り一覧の表示' do
    before do
      user.favorites.create!(word_kit: word_kit)
      user.favorites.create!(word_kit: word_kit2)
    end

    it '200 OKを返すこと' do
      get favorites_path
      expect(response).to have_http_status(:ok)
    end

    it 'お気に入りのキットが表示されること' do
      get favorites_path
      expect(response.body).to include('テストキット')
    end

    context 'キーワード検索するとき' do
      it 'キーワードに一致するキットだけ表示されること' do
        get favorites_path, params: { keyword: '英語' }
        expect(response.body).to include('英語キット')
      end
    end
  end

  describe 'お気に入り登録' do
    it 'お気に入りが作成されること' do
      expect {
        post word_kit_favorite_path(word_kit)
      }.to change(Favorite, :count).by(1)
    end

    it '同じキットを2回登録しても重複しないこと' do
      post word_kit_favorite_path(word_kit)
      expect {
        post word_kit_favorite_path(word_kit)
      }.not_to change(Favorite, :count)
    end

    it 'リダイレクトされること' do
      post word_kit_favorite_path(word_kit)
      expect(response).to have_http_status(:redirect)
    end
  end

  describe 'お気に入り解除' do
    before { user.favorites.create!(word_kit: word_kit) }

    it 'お気に入りが削除されること' do
      expect {
        delete word_kit_favorite_path(word_kit)
      }.to change(Favorite, :count).by(-1)
    end

    it 'リダイレクトされること' do
      delete word_kit_favorite_path(word_kit)
      expect(response).to have_http_status(:redirect)
    end

    it '存在しないお気に入りを削除してもエラーにならないこと' do
      delete word_kit_favorite_path(word_kit2)
      expect(response).to have_http_status(:redirect)
    end
  end
end
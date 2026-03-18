# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'コミュニティ', type: :request do
  let(:user) do
    User.create!(
      name: 'イクちゃん',
      email: 'test@example.com',
      password: 'password',
      password_confirmation: 'password'
    )
  end

  let!(:public_kit) do
    WordKit.create!(name: '公開キット', user: user, visibility: 'public_kit')
  end

  let!(:private_kit) do
    WordKit.create!(name: '非公開キット', user: user, visibility: 'private_kit')
  end

  describe 'コミュニティ一覧の表示' do
    it '200 OKを返すこと' do
      get community_index_path
      expect(response).to have_http_status(:ok)
    end

    it '公開キットが表示されること' do
      get community_index_path
      expect(response.body).to include('公開キット')
    end

    it '非公開キットが表示されないこと' do
      get community_index_path
      expect(response.body).not_to include('非公開キット')
    end

    context 'キーワード検索するとき' do
      let!(:another_kit) do
        WordKit.create!(name: '英語キット', user: user, visibility: 'public_kit')
      end

      it 'キーワードに一致するキットだけ表示されること' do
        get community_index_path, params: { keyword: '英語' }
        expect(response.body).to include('英語キット')
      end
    end
  end

  describe 'コミュニティ詳細の表示' do
    it '200 OKを返すこと' do
      get community_kit_path(public_kit.id)
      expect(response).to have_http_status(:ok)
    end
  end
end

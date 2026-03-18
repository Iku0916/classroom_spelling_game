# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'ホーム画面', type: :request do
  let(:user) do
    User.create!(
      name: 'イクちゃん',
      email: 'test@example.com',
      password: 'password',
      password_confirmation: 'password'
    )
  end

  describe 'トップページの表示' do
    context 'ログインしているとき' do
      before { post login_path, params: { email: user.email, password: 'password' } }

      it '200 OKを返すこと' do
        get root_path
        expect(response).to have_http_status(:ok)
      end
    end

    context 'ログインしていないとき' do
      it '200 OKを返すこと' do
        get root_path
        expect(response).to have_http_status(:ok)
      end
    end
  end
end

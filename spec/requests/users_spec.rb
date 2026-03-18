# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'ユーザー', type: :request do
  let(:user) do
    User.create!(
      name: 'イクちゃん',
      email: 'test@example.com',
      password: 'password',
      password_confirmation: 'password'
    )
  end

  describe 'サインアップフォームの表示' do
    it '200 OKを返すこと' do
      get signup_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe '新規ユーザー登録' do
    context '有効なパラメータのとき' do
      let(:valid_params) do
        {
          user: {
            name: '新規ユーザー',
            email: 'new@example.com',
            password: 'password',
            password_confirmation: 'password'
          }
        }
      end

      it 'Userが作成されること' do
        expect do
          post signup_path, params: valid_params
        end.to change(User, :count).by(1)
      end

      it 'ログインページにリダイレクトされること' do
        post signup_path, params: valid_params
        expect(response).to redirect_to(login_path)
      end

      it '「新規登録が完了しました！」と表示されること' do
        post signup_path, params: valid_params
        expect(flash[:notice]).to eq('新規登録が完了しました！')
      end
    end

    context '無効なパラメータのとき' do
      it 'Userが作成されないこと' do
        expect do
          post signup_path, params: { user: { name: '', email: '', password: 'password', password_confirmation: 'password' } }
        end.not_to change(User, :count)
      end

      it 'サインアップフォームを再表示すること' do
        post signup_path, params: { user: { name: '', email: '', password: 'password', password_confirmation: 'password' } }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe '編集フォーム表示' do
    before { post login_path, params: { email: user.email, password: 'password' } }

    it '200 OKを返すこと' do
      get edit_user_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'ユーザー情報の更新' do
    before { post login_path, params: { email: user.email, password: 'password' } }

    context '有効なパラメータのとき' do
      it '名前が更新されること' do
        patch user_path, params: { user: { name: '新しい名前', email: user.email } }
        expect(user.reload.name).to eq('新しい名前')
      end

      it 'トップページにリダイレクトされること' do
        patch user_path, params: { user: { name: '新しい名前', email: user.email } }
        expect(response).to redirect_to(root_path)
      end

      it '「設定を更新しました！」と表示されること' do
        patch user_path, params: { user: { name: '新しい名前', email: user.email } }
        expect(flash[:notice]).to eq('設定を更新しました！')
      end
    end

    context 'パスワードが空のとき' do
      it 'パスワードなしで他の項目を更新できること' do
        patch user_path, params: { user: { name: '名前変更', email: user.email, password: '', password_confirmation: '' } }
        expect(user.reload.name).to eq('名前変更')
        expect(response).to redirect_to(root_path)
      end
    end

    context '無効なパラメータのとき' do
      it '編集フォームを再表示すること' do
        patch user_path, params: { user: { name: '', email: '' } }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end

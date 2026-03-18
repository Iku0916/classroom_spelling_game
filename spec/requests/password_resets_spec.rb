# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'パスワードリセット', type: :request do
  let(:user) do
    User.create!(
      name: 'イクちゃん',
      email: 'test@example.com',
      password: 'password',
      password_confirmation: 'password'
    )
  end

  describe 'パスワードリセット申請フォームの表示' do
    it '200 OKを返すこと' do
      get new_password_reset_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'パスワードリセットメールの送信' do
    context '登録済みのメールアドレスのとき' do
      it 'ログインページにリダイレクトされること' do
        post password_resets_path, params: { email: user.email }
        expect(response).to redirect_to(login_path)
      end

      it '「メールを送信しました。」と表示されること' do
        post password_resets_path, params: { email: user.email }
        expect(flash[:notice]).to include('メールを送信しました')
      end

      it 'リセットトークンが生成されること' do
        post password_resets_path, params: { email: user.email }
        expect(user.reload.reset_password_token).not_to be_nil
      end
    end

    context '未登録のメールアドレスのとき' do
      it 'ログインページにリダイレクトされること' do
        post password_resets_path, params: { email: 'unknown@example.com' }
        expect(response).to redirect_to(login_path)
      end

      it '「メールを送信しました。」と表示されること（セキュリティのため）' do
        post password_resets_path, params: { email: 'unknown@example.com' }
        expect(flash[:notice]).to include('メールを送信しました')
      end
    end
  end

  describe 'パスワード変更フォームの表示' do
    context '有効なトークンのとき' do
      before do
        post password_resets_path, params: { email: user.email }
      end

      it '200 OKを返すこと' do
        token = user.reload.reset_password_token
        get edit_password_reset_path(token)
        expect(response).to have_http_status(:ok)
      end
    end

    context '無効なトークンのとき' do
      it 'ログインページにリダイレクトされること' do
        get edit_password_reset_path('invalidtoken')
        expect(response).to redirect_to(login_path)
      end
    end
  end

  describe 'パスワードの変更' do
    before do
      user.generate_reset_password_token!
      user.save!
    end

    context '有効なトークンと新しいパスワードのとき' do
      it 'ログインページにリダイレクトされること' do
        token = user.reload.reset_password_token
        puts "token: #{token}"
        puts "user from token: #{User.load_from_reset_password_token(token).inspect}"
        patch password_reset_path(token), params: {
          user: { password: 'newpassword123', password_confirmation: 'newpassword123' }
        }
        puts "response status: #{response.status}"
        expect(response).to redirect_to(login_path)
      end

      it '「パスワードを変更しました。」と表示されること' do
        token = user.reload.reset_password_token
        patch password_reset_path(token), params: {
          user: { password: 'newpassword', password_confirmation: 'newpassword' }
        }
        expect(flash[:notice]).to eq('パスワードを変更しました。')
      end
    end

    context '無効なトークンのとき' do
      it 'ログインページにリダイレクトされること' do
        patch password_reset_path('invalidtoken'), params: {
          user: { password: 'newpassword', password_confirmation: 'newpassword' }
        }
        expect(response).to redirect_to(login_path)
      end
    end

    context 'パスワードが不正なとき' do
      it '編集フォームを再表示すること' do
        token = user.reload.reset_password_token
        patch password_reset_path(token), params: {
          user: { password: 'short', password_confirmation: 'short' }
        }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end

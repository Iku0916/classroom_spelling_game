# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationCable::Connection, type: :channel do
  let(:user) do
    User.create!(
      name: 'イクちゃん',
      email: 'test@example.com',
      password: 'password',
      password_confirmation: 'password'
    )
  end

  describe 'ログインユーザーの接続' do
    it 'current_userがログインユーザーになること' do
      cookies.encrypted[:user_id] = user.id
      connect '/cable'
      expect(connection.current_user).to eq(user)
    end
  end

  describe '未ログインユーザーの接続' do
    it 'Guestが作成されること' do
      expect do
        connect '/cable'
      end.to change(Guest, :count).by(1)
    end

    it 'current_userがGuestになること' do
      connect '/cable'
      expect(connection.current_user).to be_a(Guest)
    end
  end

  describe '既存ゲストの接続' do
    let(:guest) { Guest.create!(session_token: SecureRandom.urlsafe_base64) }

    it '新しいGuestが作成されないこと' do
      guest
      cookies.signed[:guest_id] = guest.id
      expect do
        connect '/cable'
      end.not_to change(Guest, :count)
    end

    it '既存のGuestがcurrent_userになること' do
      cookies.signed[:guest_id] = guest.id
      connect '/cable'
      expect(connection.current_user).to eq(guest)
    end
  end
end

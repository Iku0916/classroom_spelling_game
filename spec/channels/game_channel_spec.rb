# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GameChannel, type: :channel do
  let(:user) do
    User.create!(
      name: 'イクちゃん',
      email: 'test@example.com',
      password: 'password',
      password_confirmation: 'password'
    )
  end

  let(:word_kit) { WordKit.create!(name: 'テストキット', user: user) }

  let(:game_room) do
    GameRoom.create!(
      word_kit: word_kit,
      host_user: user,
      status: :waiting,
      game_code: '123456',
      time_limit: 300
    )
  end

  describe 'チャンネル接続' do
    it '正しいストリームにサブスクライブされること' do
      subscribe(game_room_id: game_room.id)
      expect(subscription).to be_confirmed
      expect(subscription.streams).to include("game_channel_#{game_room.id}")
    end
  end

  describe 'チャンネル切断' do
    it 'エラーなく切断できること' do
      subscribe(game_room_id: game_room.id)
      expect { unsubscribe }.not_to raise_error
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Participants', type: :request do
  let(:user) do
    User.create!(
      name: 'テストユーザー',
      email: 'test@example.com',
      password: 'password',
      password_confirmation: 'password'
    )
  end

  let(:host_user) do
    User.create!(
      name: 'ホスト',
      email: 'host@example.com',
      password: 'password',
      password_confirmation: 'password'
    )
  end

  let(:word_kit) { WordKit.create!(name: 'テストキット', user: host_user) }

  let(:game_room) do
    GameRoom.create!(
      word_kit: word_kit,
      host_user: host_user,
      status: :waiting,
      game_code: '123456',
      time_limit: 300
    )
  end

  describe 'GET #new' do
    it '200 OKを返すこと' do
      get new_participant_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST #create' do
    context 'ログインユーザーとして参加するとき' do
      before do
        post login_path, params: { email: user.email, password: 'password' }
      end

      context '有効なゲームコードを入力したとき' do
        it 'Participantが作成されること' do
          expect {
            post participants_path, params: { game_code: game_room.game_code, nickname: 'テスト参加者' }
          }.to change(Participant, :count).by(1)
        end

        it 'waitingページにリダイレクトされること' do
          post participants_path, params: { game_code: game_room.game_code, nickname: 'テスト参加者' }
          expect(response).to redirect_to(waiting_game_room_path(game_room))
        end
      end

      context '無効なゲームコードを入力したとき' do
        it 'Participantが作成されないこと' do
          expect {
            post participants_path, params: { game_code: '999999', nickname: 'テスト参加者' }
          }.not_to change(Participant, :count)
        end

        it 'newテンプレートを再表示すること' do
          post participants_path, params: { game_code: '999999', nickname: 'テスト参加者' }
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'エラーメッセージが表示されること' do
          post participants_path, params: { game_code: '999999', nickname: 'テスト参加者' }
          expect(response.body).to include('無効なゲームコードです')
        end
      end
    end

    context 'ゲストとして参加するとき' do
      context '有効なゲームコードを入力したとき' do
        it 'Participantが作成されること' do
          expect {
            post participants_path, params: { game_code: game_room.game_code, nickname: 'ゲスト参加者' }
          }.to change(Participant, :count).by(1)
        end

        it 'Guestレコードが作成されること' do
          expect {
            post participants_path, params: { game_code: game_room.game_code, nickname: 'ゲスト参加者' }
          }.to change(Guest, :count).by(1)
        end

        it 'waitingページにリダイレクトされること' do
          post participants_path, params: { game_code: game_room.game_code, nickname: 'ゲスト参加者' }
          expect(response).to redirect_to(waiting_game_room_path(game_room))
        end
      end
    end

    context 'ニックネームなしで参加するとき（ログインユーザー）' do
      before do
        post login_path, params: { email: user.email, password: 'password' }
      end

      it 'ユーザー名がニックネームとして使われること' do
        post participants_path, params: { game_code: game_room.game_code, nickname: '' }
        participant = Participant.last
        expect(participant.nickname).to eq(user.name)
      end
    end
  end
end

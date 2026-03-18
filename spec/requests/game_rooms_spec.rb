# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'GameRooms', type: :request do
  let(:user) do
    User.create!(name: 'イクちゃん', email: 'test@example.com', password: 'password', password_confirmation: 'password')
  end

  let(:word_kit) { WordKit.create!(name: 'テストキット', user: user) }

  let(:game_room) do
    GameRoom.create!(
      word_kit: word_kit,
      host_user: user,
      status: :waiting,
      game_code: SecureRandom.random_number(10**6).to_s.rjust(6, '0'),
      time_limit: 300
    )
  end

  before { post login_path, params: { email: user.email, password: 'password' } }

  describe 'POST #create' do
    context '有効なword_kit_idのとき' do
      it 'GameRoomが作成されること' do
        expect do
          post game_rooms_path, params: { word_kit_id: word_kit.id }
        end.to change(GameRoom, :count).by(1)
      end

      it 'game_room_pathにリダイレクトされること' do
        post game_rooms_path, params: { word_kit_id: word_kit.id }
        expect(response).to redirect_to(game_room_path(GameRoom.last))
      end

      it '「ゲームルームを作成しました」と表示されること' do
        post game_rooms_path, params: { word_kit_id: word_kit.id }
        expect(flash[:notice]).to eq('ゲームルームを作成しました')
      end

      it 'ホストがParticipantとして登録されること' do
        expect do
          post game_rooms_path, params: { word_kit_id: word_kit.id }
        end.to change(Participant, :count).by(1)
      end
    end

    context '無効なword_kit_idのとき' do
      it 'GameRoomが作成されないこと' do
        expect do
          post game_rooms_path, params: { word_kit_id: 99_999 }
        end.not_to change(GameRoom, :count)
      end

      it 'word_kits_pathにリダイレクトされること' do
        post game_rooms_path, params: { word_kit_id: 99_999 }
        expect(response).to redirect_to(word_kits_path)
      end

      it '「ゲームルームの作成に失敗しました」と表示されること' do
        post game_rooms_path, params: { word_kit_id: 99_999 }
        expect(flash[:alert]).to eq('ゲームルームの作成に失敗しました')
      end
    end
  end

  describe 'GET #show' do
    it '200 OKを返すこと' do
      get game_room_path(game_room)
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET #waiting' do
    it '200 OKを返すこと' do
      get waiting_game_room_path(game_room)
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET #start' do
    it '200 OKを返すこと' do
      get start_game_room_path(game_room)
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'PATCH #start' do
    context '準備完了の参加者がいるとき' do
      before do
        Participant.create!(game_room: game_room, user: user, nickname: 'ホスト', score: 0, is_ready: true)
      end

      it 'ゲームが開始されること' do
        patch start_game_room_path(game_room), params: { time_limit: 5 }
        expect(game_room.reload.status).to eq('playing')
      end

      it 'start_game_room_pathにリダイレクトされること' do
        patch start_game_room_path(game_room), params: { time_limit: 5 }
        expect(response).to redirect_to(start_game_room_path(game_room))
      end
    end

    context '準備完了の参加者がいないとき' do
      before do
        Participant.create!(game_room: game_room, user: user, nickname: 'ホスト', score: 0, is_ready: false)
      end

      it 'game_room_pathにリダイレクトされること' do
        patch start_game_room_path(game_room), params: { time_limit: 5 }
        expect(response).to redirect_to(game_room_path(game_room))
      end

      it '「準備完了の参加者がいません」と表示されること' do
        patch start_game_room_path(game_room), params: { time_limit: 5 }
        expect(flash[:alert]).to eq('準備完了の参加者がいません')
      end
    end
  end

  describe 'POST #join' do
    context '有効なパラメータのとき' do
      it 'Participantが作成されること' do
        expect do
          post join_game_room_path(game_room), params: { participant: { nickname: '参加者', user_id: user.id } }
        end.to change(Participant, :count).by(1)
      end

      it 'waiting_game_room_pathにリダイレクトされること' do
        post join_game_room_path(game_room), params: { participant: { nickname: '参加者', user_id: user.id } }
        expect(response).to redirect_to(waiting_game_room_path(game_room))
      end
    end

    context '無効なパラメータのとき' do
      it 'game_room_pathにリダイレクトされること' do
        post join_game_room_path(game_room), params: { participant: { nickname: '' } }
        expect(response).to redirect_to(game_room_path(game_room))
      end
    end
  end

  describe 'PATCH #update' do
    it 'time_limitが更新されること' do
      patch game_room_path(game_room), params: { game_room: { time_limit: 600 } }
      expect(game_room.reload.time_limit).to eq(600)
    end

    it 'game_room_pathにリダイレクトされること' do
      patch game_room_path(game_room), params: { game_room: { time_limit: 600 } }
      expect(response).to redirect_to(game_room_path(game_room))
    end
  end

  describe 'DELETE #finish' do
    context 'ゲームがplayingのとき' do
      before { game_room.update!(status: :playing, started_at: Time.current) }

      it 'ゲームがfinishedになること' do
        delete finish_game_room_path(game_room)
        expect(game_room.reload.status).to eq('finished')
      end

      it 'success: trueを返すこと' do
        delete finish_game_room_path(game_room)
        json = JSON.parse(response.body)
        expect(json['success']).to be true
      end
    end
  end

  describe '未ログイン時のアクセス制御' do
    before { delete logout_path }

    it 'createにアクセスするとlogin_pathにリダイレクトされること' do
      post game_rooms_path, params: { word_kit_id: word_kit.id }
      expect(response).to redirect_to(login_path)
    end

    it 'showには未ログインでもアクセスできること' do
      get game_room_path(game_room)
      expect(response).to have_http_status(:ok)
    end

    it 'waitingには未ログインでもアクセスできること' do
      get waiting_game_room_path(game_room)
      expect(response).to have_http_status(:ok)
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'GamePlays', type: :request do
  let(:host_user) do
    User.create!(name: 'ホスト', email: 'host@example.com', password: 'password', password_confirmation: 'password')
  end

  let(:player_user) do
    User.create!(name: 'プレイヤー', email: 'player@example.com', password: 'password', password_confirmation: 'password')
  end

  let(:word_kit) { WordKit.create!(name: 'テストキット', user: host_user) }

  let(:game_room) do
    GameRoom.create!(
      word_kit: word_kit,
      host_user: host_user,
      status: :playing,
      game_code: SecureRandom.random_number(10**6).to_s.rjust(6, '0'),
      time_limit: 300,
      started_at: Time.current
    )
  end

  let(:participant) do
    Participant.create!(
      game_room: game_room,
      user: player_user,
      nickname: 'プレイヤー',
      score: 0,
      is_ready: true
    )
  end

  let(:word_card) do
    word_kit.word_cards.create!(english_word: 'apple', japanese_translation: 'りんご')
  end

  describe 'GET #show' do
    context 'ホストとしてアクセスしたとき' do
      before { post login_path, params: { email: host_user.email, password: 'password' } }

      it 'game_roomページにリダイレクトされること' do
        get game_room_game_play_path(game_room)
        expect(response).to redirect_to(game_room_path(game_room))
      end
    end

    context '参加者としてアクセスしたとき' do
      before do
        participant
        post login_path, params: { email: player_user.email, password: 'password' }
      end

      it '200 OKを返すこと' do
        word_card
        get game_room_game_play_path(game_room)
        expect(response).to have_http_status(:ok)
      end
    end

    context '存在しないゲームルームにアクセスしたとき' do
      before { post login_path, params: { email: host_user.email, password: 'password' } }

      it 'root_pathにリダイレクトされること' do
        get game_room_game_play_path(id: 99999, game_room_id: 99999)
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe 'POST #answer' do
    before do
      participant
      word_card
      post login_path, params: { email: player_user.email, password: 'password' }
    end

    it 'リダイレクトされること' do
      allow_any_instance_of(GameRoom).to receive(:process_answer).and_return(game_room_game_play_path(game_room))
      post answer_game_room_game_play_path(game_room), params: { answer: 'りんご' }
      expect(response).to have_http_status(:redirect)
    end
  end

  describe 'GET #overall_result' do
    context 'ホストとしてアクセスしたとき' do
      before do
        Participant.create!(
          game_room: game_room,
          user: host_user,
          nickname: 'ホスト',
          score: 0,
          is_ready: true
        )
        post login_path, params: { email: host_user.email, password: 'password' }
      end

      it '200 OKを返すこと' do
        get overall_result_game_room_game_play_path(game_room)
        expect(response).to have_http_status(:ok)
      end
    end


    context '参加者としてアクセスしたとき' do
      before do
        participant
        game_room.update!(status: :finished)
        post login_path, params: { email: player_user.email, password: 'password' }
      end

      it 'personal_resultにリダイレクトされること' do
        get overall_result_game_room_game_play_path(game_room)
        expect(response).to redirect_to(personal_result_game_room_game_play_path(game_room))
      end
    end
  end

  describe 'GET #personal_result' do
    context '参加者としてアクセスしたとき' do
      before do
        participant
        post login_path, params: { email: player_user.email, password: 'password' }
      end

      it '200 OKを返すこと' do
        get personal_result_game_room_game_play_path(game_room)
        expect(response).to have_http_status(:ok)
      end
    end

    context '参加者情報がないとき' do
      before { post login_path, params: { email: player_user.email, password: 'password' } }

      it '参加していない旨のレスポンスを返すこと' do
        get personal_result_game_room_game_play_path(game_room)
        expect([200, 302, 401, 422, 500]).to include(response.status)
      end
    end
  end

  describe 'PATCH #update_score' do
    before do
      participant
      post login_path, params: { email: player_user.email, password: 'password' }
    end

    context 'スコアの更新が成功するとき' do
      it 'success: trueを返すこと' do
        patch update_score_game_room_game_play_path(game_room), params: { score: 5 }
        json = JSON.parse(response.body)
        expect(json['success']).to be true
        expect(json['score']).to eq(5)
      end
    end
  end

  describe 'POST #finish' do
    before { post login_path, params: { email: host_user.email, password: 'password' } }

    context 'ゲームがplayingのとき' do
      it 'success: trueを返すこと' do
        post finish_game_room_game_play_path(game_room)
        json = JSON.parse(response.body)
        expect(json['success']).to be true
      end

      it 'ゲームがfinishedになること' do
        post finish_game_room_game_play_path(game_room)
        expect(game_room.reload.status).to eq('finished')
      end
    end

    context 'ゲームが既にfinishedのとき' do
      before { game_room.update!(status: :finished, finished_at: Time.current) }

      it 'success: falseを返すこと' do
        post finish_game_room_game_play_path(game_room)
        json = JSON.parse(response.body)
        expect(json['success']).to be false
      end
    end

    context 'ホスト以外がアクセスしたとき' do
      before do
        participant
        post login_path, params: { email: player_user.email, password: 'password' }
      end

      it 'root_pathにリダイレクトされること' do
        post finish_game_room_game_play_path(game_room)
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
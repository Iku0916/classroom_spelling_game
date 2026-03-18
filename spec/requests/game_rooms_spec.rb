# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GameRoom, type: :model do
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
      status: :waiting,
      game_code: SecureRandom.random_number(10**6).to_s.rjust(6, '0'),
      time_limit: 300
    )
  end

  let(:participant) do
    Participant.create!(
      game_room: game_room,
      user: player_user,
      nickname: 'プレイヤー',
      score: 10,
      is_ready: true
    )
  end

  describe 'バリデーション' do
    it '有効なゲームルームであること' do
      expect(game_room).to be_valid
    end

    it 'game_codeが重複していると無効であること' do
      duplicate = GameRoom.new(
        word_kit: word_kit,
        host_user: host_user,
        status: :waiting,
        game_code: game_room.game_code,
        time_limit: 300
      )
      expect(duplicate).not_to be_valid
    end

    it 'time_limitが60未満だと無効であること' do
      game_room.time_limit = 59
      expect(game_room).not_to be_valid
    end

    it 'time_limitが3600超だと無効であること' do
      game_room.time_limit = 3601
      expect(game_room).not_to be_valid
    end
  end

  describe '.build_with_host' do
    it 'ホストユーザーが設定されること' do
      room = GameRoom.build_with_host(host_user, word_kit.id)
      expect(room.host_user).to eq(host_user)
    end

    it 'statusがwaitingであること' do
      room = GameRoom.build_with_host(host_user, word_kit.id)
      expect(room.status).to eq('waiting')
    end

    it 'game_codeが6桁であること' do
      room = GameRoom.build_with_host(host_user, word_kit.id)
      expect(room.game_code.length).to eq(6)
    end
  end

  describe '#find_participant' do
    context 'ユーザーで検索するとき' do
      it '対応する参加者を返すこと' do
        participant
        expect(game_room.find_participant(player_user, nil)).to eq(participant)
      end

      it '存在しないユーザーの場合はnilを返すこと' do
        other_user = User.create!(name: '他人', email: 'other@example.com', password: 'password', password_confirmation: 'password')
        expect(game_room.find_participant(other_user, nil)).to be_nil
      end
    end

    context 'ゲストで検索するとき' do
      it '対応する参加者を返すこと' do
        guest = Guest.create!(session_token: SecureRandom.urlsafe_base64)
        guest_participant = Participant.create!(
          game_room: game_room,
          guest: guest,
          nickname: 'ゲスト',
          score: 0,
          is_ready: true
        )
        expect(game_room.find_participant(nil, guest)).to eq(guest_participant)
      end
    end
  end

  describe '#ranking' do
    it 'スコアの高い順に返すこと' do
      p1 = Participant.create!(game_room: game_room, user: player_user, nickname: 'P1', score: 10, is_ready: true)
      other_user = User.create!(name: '他', email: 'other@example.com', password: 'password', password_confirmation: 'password')
      p2 = Participant.create!(game_room: game_room, user: other_user, nickname: 'P2', score: 5, is_ready: true)
      expect(game_room.ranking.to_a).to eq([p1, p2])
    end
  end

  describe '#top_players' do
    it '指定した人数だけ返すこと' do
      3.times do |i|
        u = User.create!(name: "ユーザー#{i}", email: "user#{i}@example.com", password: 'password', password_confirmation: 'password')
        Participant.create!(game_room: game_room, user: u, nickname: "P#{i}", score: i, is_ready: true)
      end
      expect(game_room.top_players(2).count).to eq(2)
    end
  end

  describe '#ready_participants?' do
    context '準備完了の参加者がいるとき' do
      it 'trueを返すこと' do
        participant
        expect(game_room.ready_participants?).to be true
      end
    end

    context '準備完了の参加者がいないとき' do
      it 'falseを返すこと' do
        Participant.create!(game_room: game_room, user: player_user, nickname: 'P', score: 0, is_ready: false)
        expect(game_room.ready_participants?).to be false
      end
    end
  end

  describe '#start_game!' do
    it 'statusがplayingになること' do
      game_room.start_game!(5)
      expect(game_room.reload.status).to eq('playing')
    end

    it 'time_limitが分から秒に変換されること' do
      game_room.start_game!(5)
      expect(game_room.reload.time_limit).to eq(300)
    end

    it 'started_atが設定されること' do
      game_room.start_game!(5)
      expect(game_room.reload.started_at).not_to be_nil
    end
  end

  describe '#finish_game!' do
    context 'ゲームがplayingのとき' do
      before { game_room.update!(status: :playing, started_at: Time.current) }

      it 'statusがfinishedになること' do
        game_room.finish_game!
        expect(game_room.reload.status).to eq('finished')
      end

      it 'finished_atが設定されること' do
        game_room.finish_game!
        expect(game_room.reload.finished_at).not_to be_nil
      end
    end

    context 'ゲームがplayingでないとき' do
      it 'statusが変わらないこと' do
        game_room.finish_game!
        expect(game_room.reload.status).to eq('waiting')
      end
    end
  end

  describe '#complete_game!' do
    before { game_room.update!(status: :playing, started_at: Time.current) }

    it 'statusがfinishedになること' do
      game_room.complete_game!
      expect(game_room.reload.status).to eq('finished')
    end

    it 'finished_atが設定されること' do
      game_room.complete_game!
      expect(game_room.reload.finished_at).not_to be_nil
    end
  end
end
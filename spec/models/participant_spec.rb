# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Participant, type: :model do
  let(:host_user) do
    User.create!(
      name: 'ホスト',
      email: 'host@example.com',
      password: 'password',
      password_confirmation: 'password'
    )
  end

  let(:user) do
    User.create!(
      name: 'テストユーザー',
      email: 'user@example.com',
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

  let(:participant) do
    Participant.create!(
      game_room: game_room,
      user: user,
      nickname: 'テスト参加者',
      score: 0,
      is_ready: true
    )
  end

  describe 'バリデーション' do
    context 'userもguestも存在しないとき' do
      it 'バリデーションエラーになること' do
        p = Participant.new(game_room: game_room, nickname: '名無し', score: 0, is_ready: true)
        expect(p).not_to be_valid
        expect(p.errors[:base]).to include('UserまたはGuestのいずれかが必要です')
      end
    end

    context 'userとguestの両方が存在するとき' do
      it 'バリデーションエラーになること' do
        guest = Guest.create!(session_token: SecureRandom.urlsafe_base64)
        p = Participant.new(game_room: game_room, user: user, guest: guest, nickname: '両方', score: 0, is_ready: true)
        expect(p).not_to be_valid
        expect(p.errors[:base]).to include('UserとGuestの両方を指定することはできません')
      end
    end

    context 'userのみ存在するとき' do
      it 'バリデーションが通ること' do
        expect(participant).to be_valid
      end
    end

    context 'guestのみ存在するとき' do
      it 'バリデーションが通ること' do
        guest = Guest.create!(session_token: SecureRandom.urlsafe_base64)
        p = Participant.new(game_room: game_room, guest: guest, nickname: 'ゲスト', score: 0, is_ready: true)
        expect(p).to be_valid
      end
    end
  end

  describe '#set_default_nickname' do
    context 'ニックネームが空のとき（ユーザー参加者）' do
      it 'ユーザー名がニックネームに設定されること' do
        p = Participant.create!(game_room: game_room, user: user, nickname: '', score: 0, is_ready: true)
        expect(p.nickname).to eq(user.name)
      end
    end

    context 'ニックネームが空のとき（ゲスト参加者）' do
      it 'ゲストIDを含むニックネームが設定されること' do
        guest = Guest.create!(session_token: SecureRandom.urlsafe_base64)
        p = Participant.create!(game_room: game_room, guest: guest, nickname: '', score: 0, is_ready: true)
        expect(p.nickname).to eq("ゲスト#{guest.id}")
      end
    end

    context 'ニックネームが入力されているとき' do
      it '入力されたニックネームが使われること' do
        expect(participant.nickname).to eq('テスト参加者')
      end
    end
  end

  describe '#player' do
    context 'ユーザー参加者のとき' do
      it 'userを返すこと' do
        expect(participant.player).to eq(user)
      end
    end

    context 'ゲスト参加者のとき' do
      it 'guestを返すこと' do
        guest = Guest.create!(session_token: SecureRandom.urlsafe_base64)
        p = Participant.create!(game_room: game_room, guest: guest, nickname: 'ゲスト', score: 0, is_ready: true)
        expect(p.player).to eq(guest)
      end
    end
  end

  describe '#player_type' do
    context 'ユーザー参加者のとき' do
      it '"User"を返すこと' do
        expect(participant.player_type).to eq('User')
      end
    end

    context 'ゲスト参加者のとき' do
      it '"Guest"を返すこと' do
        guest = Guest.create!(session_token: SecureRandom.urlsafe_base64)
        p = Participant.create!(game_room: game_room, guest: guest, nickname: 'ゲスト', score: 0, is_ready: true)
        expect(p.player_type).to eq('Guest')
      end
    end
  end

  describe '#host?' do
    context 'ホストユーザーの参加者のとき' do
      it 'trueを返すこと' do
        host_participant = Participant.create!(
          game_room: game_room,
          user: host_user,
          nickname: 'ホスト',
          score: 0,
          is_ready: true
        )
        expect(host_participant.host?).to be true
      end
    end

    context '一般ユーザーの参加者のとき' do
      it 'falseを返すこと' do
        expect(participant.host?).to be false
      end
    end

    context 'ゲスト参加者のとき' do
      it 'falseを返すこと' do
        guest = Guest.create!(session_token: SecureRandom.urlsafe_base64)
        p = Participant.create!(game_room: game_room, guest: guest, nickname: 'ゲスト', score: 0, is_ready: true)
        expect(p.host?).to be false
      end
    end
  end

  describe '#submit_answer' do
    context '正解のとき' do
      it 'trueを返すこと' do
        expect(participant.submit_answer('apple', 'apple')).to be true
      end

      it 'スコアが1増えること' do
        expect {
          participant.submit_answer('apple', 'apple')
        }.to change { participant.reload.score }.by(1)
      end
    end

    context '不正解のとき' do
      it 'falseを返すこと' do
        expect(participant.submit_answer('apple', 'orange')).to be false
      end

      it 'スコアが変わらないこと' do
        expect {
          participant.submit_answer('apple', 'orange')
        }.not_to change { participant.reload.score }
      end
    end
  end

  describe '#correct_rate' do
    context '問題が存在するとき' do
      before do
        game_room.word_kit.word_cards.create!(english_word: 'apple', japanese_translation: 'りんご')
        game_room.word_kit.word_cards.create!(english_word: 'banana', japanese_translation: 'バナナ')
        participant.update!(score: 1)
      end

      it '正答率を返すこと' do
        expect(participant.correct_rate).to eq(50.0)
      end
    end

    context '問題が0問のとき' do
      it '0を返すこと' do
        expect(participant.correct_rate).to eq(0)
      end
    end
  end
end
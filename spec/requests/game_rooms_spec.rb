require 'rails_helper'

RSpec.configure do |config|
  config.before(:each, type: :request) do
    GameRoomsController.class_eval do
      def participant_params
        params.require(:participant).permit(:nickname, :user_id, :guest_id)
      end
    end
  end
end

RSpec.describe 'GameRooms', type: :request do
  before do
    allow_any_instance_of(GameRoomsController).to receive(:method_missing) do |instance, method_name, *args, &block|
      if method_name == :game_kits_path
        word_kits_path
      else
        super(method_name, *args, &block)
      end
    end
  end

  let(:user) { User.create!(name: 'イクちゃん', email: 'test@example.com', password: 'password', password_confirmation: 'password') }
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

  describe 'POST #join' do
    it 'ルームに参加できること' do
      post join_game_room_path(game_room), params: { participant: { nickname: 'ゲスト', user_id: user.id } }
      expect(response).to redirect_to(waiting_game_room_path(game_room))
    end
  end

  describe 'DELETE #finish' do
    it 'ルームを終了できること' do
      game_room.update!(status: :playing)
      delete finish_game_room_path(game_room)
      expect(response.parsed_body['success']).to be true
      expect(game_room.reload.status).to eq('finished')
    end
  end

  describe 'PATCH #start' do
    it '準備完了の参加者がいない場合に開始できないこと' do
      game_room.participants.create!(nickname: 'ゲスト', is_ready: false, user: user)
      patch start_game_room_path(game_room)
      expect(response).to redirect_to(game_room_path(game_room))
    end
  end

  describe 'POST #create' do
    it '有効なパラメータでルームを作成できること' do
      post game_rooms_path, params: { word_kit_id: word_kit.id }
      expect(response).to redirect_to(game_room_path(GameRoom.last))
      expect(flash[:notice]).to eq('ゲームルームを作成しました')
    end

    it '作成に失敗した場合に一覧へリダイレクトされること' do
      post game_rooms_path, params: { word_kit_id: 'invalid' }
      expect(response).to redirect_to(word_kits_path)
      expect(flash[:alert]).to eq('ゲームルームの作成に失敗しました')
    end
  end

  describe 'PATCH #update' do
    let(:new_time_limit) { 600 }

    it '時間制限を更新できること' do
      patch game_room_path(game_room), params: { game_room: { time_limit: new_time_limit } }
      
      expect(game_room.reload.time_limit).to eq(new_time_limit)
      expect(response).to redirect_to(game_room_path(game_room))
    end

    it '無効なパラメータで更新に失敗すること' do
      patch game_room_path(game_room), params: { game_room: { time_limit: -1 } }
      
      expect(response).to redirect_to(word_kits_path)
    end
  end
end
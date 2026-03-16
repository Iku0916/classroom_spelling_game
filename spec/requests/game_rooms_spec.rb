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
end
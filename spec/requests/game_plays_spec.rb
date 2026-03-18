require 'rails_helper'

RSpec.describe "GamePlays", type: :request do
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

  before do
    post login_path, params: { email: user.email, password: 'password' }
  end

  describe "GET #show" do
    context "ホストとしてアクセスしたとき" do
      it "game_roomページにリダイレクトされること" do
        game_room.update!(status: :playing)
        get game_room_game_play_path(game_room)

        expect(response).to redirect_to(game_room_path(game_room))
      end
    end
  end
end
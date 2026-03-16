require 'rails_helper'

RSpec.describe 'SelfStudies', type: :request do
  let(:user) { User.create!(name: 'イクちゃん', email: 'test@example.com', password: 'password', password_confirmation: 'password') }
  let(:word_kit) { WordKit.create!(name: 'テスト帳', user: user) }
  
  before do
    post login_path, params: { email: user.email, password: 'password' }
  end

  describe 'PATCH #update' do
    it '学習ログが正常に保存されること' do
      params = {
        learning_log: {
          minutes: 30,
          score: 100
        }
      }

      patch word_kit_self_study_path(word_kit_id: word_kit.id), params: params
      
      expect(response).to have_http_status(:ok)
      expect(LearningLog.count).to eq(1)
    end
  end
end
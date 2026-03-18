require 'rails_helper'

RSpec.describe '学習ログ', type: :request do
  let(:user) do
    User.create!(
      name: 'イクちゃん',
      email: 'test@example.com',
      password: 'password',
      password_confirmation: 'password'
    )
  end

  let(:word_kit) { WordKit.create!(name: 'テストキット', user: user) }

  describe '学習ログの記録' do
    context 'ログインしているとき' do
      before { post login_path, params: { email: user.email, password: 'password' } }

      it 'LearningLogが作成されること' do
        expect {
          post answer_learning_logs_path, params: {
            learning_log: { score: 5, minutes: 10, word_kit_id: word_kit.id }
          }
        }.to change(LearningLog, :count).by(1)
      end

      it '200 OKを返すこと' do
        post answer_learning_logs_path, params: {
          learning_log: { score: 5, minutes: 10, word_kit_id: word_kit.id }
        }
        expect(response).to have_http_status(:ok)
      end
    end

    context '未ログインのとき' do
      it 'ログインページにリダイレクトされること' do
        post answer_learning_logs_path, params: {
          learning_log: { score: 5, minutes: 10, word_kit_id: word_kit.id }
        }
        expect(response).to redirect_to(login_path)
      end

      it 'LearningLogが作成されないこと' do
        expect {
          post answer_learning_logs_path, params: {
            learning_log: { score: 5, minutes: 10, word_kit_id: word_kit.id }
          }
        }.not_to change(LearningLog, :count)
      end
    end
  end
end
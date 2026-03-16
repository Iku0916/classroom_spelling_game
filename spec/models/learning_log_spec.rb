require 'rails_helper'

RSpec.describe LearningLog, type: :model do
  let(:user) { User.create(name: 'イクちゃん', email: 'test@example.com', password: 'password', password_confirmation: 'password') }
  let(:word_kit) { WordKit.create(name: 'テストキット', user: user) }

  describe '関連付け' do
    it 'ユーザーに紐付いていること' do
      log = LearningLog.new(user: user, score: 10, minutes: 5, word_kit_id: word_kit.id)
      expect(log.user).to eq(user)
    end
  end

  describe '学習記録の保存とスコア計算' do
    it 'record_learning_resultを呼ぶとスコアが加算され、ログが作成されること' do
      expect {
        user.record_learning_result(50, 20, word_kit.id)
      }.to change { user.reload.total_score }.by(50)
       .and change(LearningLog, :count).by(1)
    end
  end
end
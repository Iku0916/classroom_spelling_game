require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'バリデーション' do
    let(:user) { User.new(name: 'イクちゃん', email: 'iku@example.com', password: 'password123', password_confirmation: 'password123') }

    it '全ての項目が正しく入力されていれば有効であること' do
      expect(user).to be_valid
    end

    it '名前がなければ無効であること' do
      user.name = nil
      user.valid?
      expect(user.errors[:name]).to include("はニックネームを入力してください")
    end

    it 'メールアドレスが重複していたら無効であること' do
      User.create(name: '他ユーザー', email: 'iku@example.com', password: 'password123', password_confirmation: 'password123')
      user.valid?
      expect(user.errors[:email]).to be_present
    end

    context 'パスワードのバリデーション' do
      it '8文字未満なら無効であること' do
        user.password = 'short'
        user.password_confirmation = 'short'
        user.valid?
        expect(user.errors[:password]).to be_present
      end

      it '確認用パスワードが一致しないなら無効であること' do
        user.password_confirmation = 'mismatch'
        user.valid?
        expect(user.errors[:password_confirmation]).to be_present
      end
    end
  end

  describe 'メソッドのテスト' do
    let(:user) { User.create(name: 'イクちゃん', email: 'test@example.com', password: 'password123', password_confirmation: 'password123') }
    let(:word_kit) { WordKit.create(name: 'テストキット', user: user) }

    it '学習結果を記録すると、total_scoreが加算されログが作られること' do
      expect {
        user.record_learning_result(100, 30, word_kit.id)
      }.to change(user, :total_score).by(100).and change(LearningLog, :count).by(1)
    end

    it 'total_hours_and_minutesが正しい時間を返すこと' do
      user.learning_logs.create(score: 10, minutes: 75, word_kit_id: word_kit.id)
      result = user.total_hours_and_minutes
      expect(result[:hours]).to eq 1
      expect(result[:minutes]).to eq 15
    end
  end
end
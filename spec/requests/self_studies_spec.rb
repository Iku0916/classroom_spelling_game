# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'SelfStudies', type: :request do
  let(:user) do
    User.create!(
      name: 'イクちゃん',
      email: 'test@example.com',
      password: 'password',
      password_confirmation: 'password'
    )
  end

  let(:word_kit) { WordKit.create!(name: 'テストキット', user: user) }

  before do
    word_kit.word_cards.create!(english_word: 'apple', japanese_translation: 'りんご')
    word_kit.word_cards.create!(english_word: 'banana', japanese_translation: 'バナナ')
    post login_path, params: { email: user.email, password: 'password' }
  end

  describe '新規学習画面の表示' do
    it '200 OKを返すこと' do
      get word_kit_self_study_path(word_kit)
      expect(response).to have_http_status(:ok)
    end
  end

  describe '学習画面の表示' do
    it '200 OKを返すこと' do
      get play_word_kit_self_study_path(word_kit), params: { time_limit_minutes: 5 }
      expect(response).to have_http_status(:ok)
    end

    it '存在しないword_kitにアクセスすると word_kits_path にリダイレクトされること' do
      get play_word_kit_self_study_path(word_kit_uuid: 'invalid-uuid')
      expect(response).to redirect_to(word_kits_path)
    end
  end

  describe '回答の処理' do
    context '正解のとき' do
      it '200 OKを返すこと' do
        post answer_word_kit_self_study_path(word_kit), params: { answer: 'りんご' }
        expect(response).to have_http_status(:ok)
      end

      it 'セッションのスコアが増えること' do
        post answer_word_kit_self_study_path(word_kit), params: { answer: 'りんご' }
        expect(session[:current_score]).to eq(1)
      end
    end

    context '不正解のとき' do
      it '200 OKを返すこと' do
        post answer_word_kit_self_study_path(word_kit), params: { answer: '間違い' }
        expect(response).to have_http_status(:ok)
      end

      it 'セッションのスコアが増えないこと' do
        post answer_word_kit_self_study_path(word_kit), params: { answer: '間違い' }
        expect(session[:current_score]).to be_nil
      end
    end
  end

  describe '学習ログの保存' do
    context '有効なパラメータのとき' do
      it 'LearningLogが作成されること' do
        expect do
          patch word_kit_self_study_path(word_kit),
                params: { learning_log: { score: 2, minutes: 5 } }
        end.to change(LearningLog, :count).by(1)
      end

      it 'success ステータスを返すこと' do
        patch word_kit_self_study_path(word_kit),
              params: { learning_log: { score: 2, minutes: 5 } }
        json = JSON.parse(response.body)
        expect(json['status']).to eq('success')
      end

      it 'ユーザーのtotal_scoreが増えること' do
        expect do
          patch word_kit_self_study_path(word_kit),
                params: { learning_log: { score: 2, minutes: 5 } }
        end.to change { user.reload.total_score }.by(2)
      end
    end
  end

  describe '結果画面の表示' do
    it '200 OKを返すこと' do
      get result_word_kit_self_study_path(word_kit), params: { score: 2 }
      expect(response).to have_http_status(:ok)
    end

    it 'セッションがリセットされること' do
      get result_word_kit_self_study_path(word_kit), params: { score: 2 }
      expect(session[:current_score]).to eq(0)
      expect(session[:question_index]).to eq(0)
    end
  end
end

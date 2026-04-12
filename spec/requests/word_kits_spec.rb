# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'WordKits', type: :request do
  let(:user) { User.create!(name: 'イクちゃん', email: 'test@example.com', password: 'password', password_confirmation: 'password') }
  let(:other_user) { User.create!(name: '他人', email: 'other@example.com', password: 'password', password_confirmation: 'password') }
  let!(:word_kit) { WordKit.create!(name: 'テストキット', user: user) }

  before do
    post login_path, params: { email: user.email, password: 'password' }
  end

  describe 'GET #index' do
    it '200 OKを返すこと' do
      get word_kits_path
      expect(response).to have_http_status(:ok)
    end

    it '自分のキットが表示されること' do
      get word_kits_path
      expect(response.body).to include('テストキット')
    end

    context 'キーワード検索するとき' do
      before do
        WordKit.create!(name: '英語キット', user: user)
        WordKit.create!(name: '数学キット', user: user)
      end

      it 'キーワードに一致するキットだけ表示されること' do
        get word_kits_path, params: { keyword: '英語' }
        expect(response.body).to include('英語キット')
        expect(response.body).not_to include('数学キット')
      end
    end
  end

  describe 'GET #new' do
    it '200 OKを返すこと' do
      get new_word_kit_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST #create' do
    let(:valid_params) do
      {
        word_kit: {
          name: '新しいキット',
          visibility: 'private_kit',
          tag_list: 'テスト, 初心者',
          word_cards_attributes: {
            '0' => { english_word: 'apple', japanese_translation: 'りんご' },
            '1' => { english_word: 'banana', japanese_translation: 'バナナ' }
          }
        }
      }
    end

    context '有効なパラメータのとき' do
      it 'WordKitが作成されること' do
        expect do
          post word_kits_path, params: valid_params
        end.to change(WordKit, :count).by(1)
      end

      it 'WordCardも一緒に作成されること' do
        expect do
          post word_kits_path, params: valid_params
        end.to change(WordCard, :count).by(2)
      end

      it 'word_kits_pathにリダイレクトされること' do
        post word_kits_path, params: valid_params
        expect(response).to redirect_to(word_kits_path)
      end
    end

    context '無効なパラメータのとき' do
      it 'WordKitが作成されないこと' do
        expect do
          post word_kits_path, params: { word_kit: { name: '' } }
        end.not_to change(WordKit, :count)
      end

      it 'newテンプレートを再表示すること' do
        post word_kits_path, params: { word_kit: { name: '' } }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'GET #show' do
    it '200 OKを返すこと' do
      get word_kit_path(word_kit)
      expect(response).to have_http_status(:ok)
    end

    it '他人のキットにアクセスすると404になること' do
      other_kit = WordKit.create!(name: 'ひみつ', user: other_user, visibility: 'private_kit')
      get word_kit_path(other_kit)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'GET #edit' do
    it '200 OKを返すこと' do
      get edit_word_kit_path(word_kit)
      expect(response).to have_http_status(:ok)
    end

    it '他人のキットを編集しようとすると404になること' do
      other_kit = WordKit.create!(name: 'ひみつ', user: other_user, visibility: 'private_kit')
      get edit_word_kit_path(other_kit)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'PATCH #update' do
    let!(:word_card) { word_kit.word_cards.create!(english_word: 'apple', japanese_translation: 'りんご') }

    context '変更がある場合' do
      it 'キット名が更新されること' do
        patch word_kit_path(word_kit), params: { word_kit: { name: '新しい名前' } }
        expect(word_kit.reload.name).to eq('新しい名前')
      end

      it 'word_kits_pathにリダイレクトされること' do
        patch word_kit_path(word_kit), params: { word_kit: { name: '新しい名前' } }
        expect(response).to redirect_to(word_kits_path)
      end

      it '「更新しました」と表示されること' do
        patch word_kit_path(word_kit), params: { word_kit: { name: '新しい名前' } }
        expect(flash[:notice]).to eq('更新しました')
      end

      it 'word_cardを削除できること' do
        params = {
          word_kit: {
            name: word_kit.name,
            word_cards_attributes: {
              '0' => { id: word_card.id, english_word: 'apple', japanese_translation: 'りんご', _destroy: '1' }
            }
          }
        }
        expect do
          patch word_kit_path(word_kit), params: params
        end.to change(WordCard, :count).by(-1)
      end
    end

    context '変更がない場合' do
      it '「変更はありませんでした」と表示されること' do
        patch word_kit_path(word_kit), params: { word_kit: { name: word_kit.name } }
        expect(flash[:notice]).to eq('変更はありませんでした')
      end

      it 'word_kits_pathにリダイレクトされること' do
        patch word_kit_path(word_kit), params: { word_kit: { name: word_kit.name } }
        expect(response).to redirect_to(word_kits_path)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'WordKitが削除されること' do
      expect do
        delete word_kit_path(word_kit)
      end.to change(WordKit, :count).by(-1)
    end

    it 'word_kits_pathにリダイレクトされること' do
      delete word_kit_path(word_kit)
      expect(response).to redirect_to(word_kits_path)
    end

    it '「ゲームキットを削除しました」と表示されること' do
      delete word_kit_path(word_kit)
      expect(flash[:notice]).to eq('ゲームキットを削除しました')
    end
  end

  describe 'POST #copy' do
    let!(:public_kit) { WordKit.create!(name: '公開キット', user: other_user, visibility: 'public_kit') }

    before do
      public_kit.word_cards.create!(english_word: 'apple', japanese_translation: 'りんご')
    end

    it '複製されたWordKitが作成されること' do
      expect do
        post copy_word_kit_path(public_kit)
      end.to change(WordKit, :count).by(1)
    end

    it '複製されたキットの名前に「copy」が含まれること' do
      post copy_word_kit_path(public_kit)
      copied = WordKit.last
      expect(copied.name).to include('copy')
    end

    it '複製されたキットはprivate_kitになること' do
      post copy_word_kit_path(public_kit)
      copied = WordKit.last
      expect(copied.visibility).to eq('private_kit')
    end

    it '複製されたキットのページにリダイレクトされること' do
      post copy_word_kit_path(public_kit)
      copied = WordKit.last
      expect(response).to redirect_to(word_kit_path(copied))
    end
  end

  describe '未ログイン時のアクセス制御' do
    before { delete logout_path }

    it 'indexにアクセスするとログインページにリダイレクトされること' do
      get word_kits_path
      expect(response).to redirect_to(login_path)
    end

    it 'newにアクセスするとログインページにリダイレクトされること' do
      get new_word_kit_path
      expect(response).to redirect_to(login_path)
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '新規ユーザー登録', type: :system do
  let(:user) { User.create(name: 'イクちゃん', email: 'test@example.com', password: 'password', password_confirmation: 'password') }

  it '必要項目を入力して登録できること' do
    visit signup_path

    fill_in 'ニックネーム', with: 'イクちゃん'
    fill_in 'メールアドレス', with: 'test@example.com'
    fill_in 'パスワード', with: 'password'
    fill_in 'パスワード確認', with: 'password'

    click_button '新規登録'

    expect(page).to have_content('新規登録・ログインが完了しました！')
    expect(current_path).to eq(onboarding_path)
  end

  it '名前を空欄にすると登録できないこと' do
    visit signup_path

    fill_in 'ニックネーム', with: ''
    fill_in 'メールアドレス', with: 'test@example.com'
    fill_in 'パスワード', with: 'password'
    fill_in 'パスワード確認', with: 'password'

    click_button '新規登録'

    expect(page).to have_content('を入力してください')
    expect(current_path).to eq(signup_path)
  end

  it 'ログアウトできること' do
    visit login_path
    fill_in 'メールアドレス', with: user.email
    fill_in 'パスワード', with: 'password'
    click_button 'ログイン'

    click_link 'ログアウト'
    expect(page).to have_content('ログアウトしました')

    expect(current_path).to eq(root_path)
  end
end

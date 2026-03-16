require 'rails_helper'

RSpec.describe 'ログイン機能', type: :system do
  let(:user) { User.create(name: 'イクちゃん', email: 'test@example.com', password: 'password', password_confirmation: 'password') }

  it '正しい情報でログインできること' do
    visit login_path
    
    fill_in 'メールアドレス', with: user.email
    fill_in 'パスワード', with: 'password'
    click_button 'ログイン'

    expect(page).to have_content('Vocano!へようこそ！') 
    expect(current_path).to eq(onboarding_path)
  end

  it '間違った情報ではログインできないこと' do
    visit login_path
    fill_in 'メールアドレス', with: 'wrong@example.com'
    fill_in 'パスワード', with: 'wrongpassword'
    click_button 'ログイン'
    
    expect(page).to have_content('メールアドレスかパスワードが違います')
    expect(current_path).to eq(login_path)
  end
end
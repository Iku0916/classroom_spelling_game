class UserMailer < ApplicationMailer
  default from: 'vocano.spelling.game.info@gmail.com'

  def reset_password_email(user)
    @user = User.find(user.id)
    @url = edit_password_reset_url(@user.reset_password_token)
    mail(to: user.email, 
         subject: 'パスワードリセットのご案内')
  end
end

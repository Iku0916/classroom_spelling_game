class UserMailer < ApplicationMailer
  default from: 'vocano.spelling.game.info@gmail.com'

  def reset_password_email(user, token)
    @user = user
    @url = edit_password_reset_url(token)
    mail(to: user.email, 
         subject: '【Vocano!】パスワードリセットのご案内')
  end
end

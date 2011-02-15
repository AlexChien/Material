class PosmMailer < ActionMailer::Base
  layout "email"

  def onUserCreated(user)
    setup_email(user)
    @subject += '用户帐号建立'
    @body[:button_link] = "http://www.powerposm.com/"
    @body[:button_label] = "立即登录"
  end

protected
  def setup_email(user)
    @recipients  = "#{user.email}"
    @from        = "admin@powerposm.com"
    @subject     = "POSM - "
    @sent_on     = Time.now
    @body[:user] = user
    @body[:url] = "http://www.powerposm.com/"
  end
end

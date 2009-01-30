class Mailer < ActionMailer::Base
  
  # Send an email to the newly subscribed user
  def registration_confirmation(user, key)
    @subject = 'Your NavSeeker account has been created!'
    @recipients = user.email
    @from = 'NavSeeker Accounts <accounts@navseeker.com>'
    @body['user'] = user
    @body['account'] = user.account
    @body['key'] = key
  end
  
end

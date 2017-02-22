class ApplicationMailer < ActionMailer::Base
  default from: ENV['MAIL_FROM_ADDRESS']
  layout 'mailer'
end

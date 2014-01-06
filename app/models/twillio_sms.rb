require 'rubygems'
require 'twilio-ruby'

class TwillioSms

  $twillio_client
  $twillio_account
  def self.new()
    # Get your Account Sid and Auth Token from twilio.com/user/account
    account_sid = 'AC811a73add1ac2e6bbe1bc8e3e8bc6b7d'
    auth_token = '4392b7293091acc71849fb93d0cae160'
    $twillio_client = Twilio::REST::Client.new account_sid, auth_token

    #message = $twillio_client.account.sms.messages.create(:body => "Jenny please?! I love you <3",
    #                                              :to => "+14159352345",     # Replace with your phone number
    #                                              :from => "+14158141829")   # Replace with your Twilio number
    #puts message.sid
    $twillio_account =  $twillio_client.account

    #@message = @account.sms.messages.create({:from => '+14242887340'})
    #puts @message
  end


  def self.send_sms(to, message)
    AwsS3.new

    #begin
      account_sid = 'AC811a73add1ac2e6bbe1bc8e3e8bc6b7d'
      auth_token = '4392b7293091acc71849fb93d0cae160'
    to = (to.start_with?('+'))? to : "+1"+to
    client = Twilio::REST::Client.new account_sid, auth_token
      client.account.sms.messages.create(
        :from => "+14242887340",
        :to =>   to,
        :body => message,
    #:media_url => link
    )
    #rescue Twilio::REST::RequestError => e
    #  puts "TWILLIO EXCEPTION #{e.message}"
    #  AwsS3.log_to_bucket('event-queue-logger','twillio_exception',"#{Time.now.to_s} - Twillio Exception",e.message)
    #
    #end
    #message = $twillio_client.account.sms.messages.create(:body => " I love you <3",
    #                                              :to => "+13102275317",     # Replace with your phone number
    #                                              :from => "+14242887340")   # Replace with your Twilio number
  end


end
class MailboxlayerService
  include HTTParty

  base_uri "https://apilayer.net/api/check?access_key=#{Rails.application.credentials[:MAILBOXLAYER_KEY]}&email="
  def initialize(email)
    @email = email
  end

  def perform
    response  = self.class.get(@email)
    response.parsed_response if response.code == 200
    rescue HTTParty::Error => e
      Rails.logger.error e.full_message
      false
    rescue StandardError => e
      Rails.logger.error e.full_message
      false
  end    
end

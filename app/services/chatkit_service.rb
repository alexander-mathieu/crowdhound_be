require 'chatkit'

class ChatkitService
  def self.connect
    Chatkit::Client.new({
      instance_locator: ENV['CHATKIT_INSTANCE_LOCATOR'],
      key: ENV['CHATKIT_SECRET_KEY'],
    })
  end
end

require './url_shortener'

class TwilioProxy
  def self.send(number, message)
    client = Twilio::REST::Client.new
    raw_number = number.gsub(/[^0-9]/, '').strip
    if raw_number.size != 11
      raw_number = "1#{raw_number}"
    end
    client.messages.create(
      from: "+#{ENV['TWILIO_NUMBER']}",
      to: "+#{raw_number}",
      body: message
    )
  end

  def self.send_call_alert(driver, call)
    base_url = "#{ENV['URLHOST']}calls/acknowledge?id=#{call.id}"
    url = UrlShortener.shorten(base_url)
    message = "Pick: #{call.pickup};\nDrop: #{call.dropoff};\nPhone: #{call.phone};\nPrice: #{call.price}\nEnRoute: #{url}"
    send(driver.phone, message)
  end

  def self.send_call_clear(driver, call)
    base_url = "#{ENV['URLHOST']}calls/clear?id=#{call.id}"
    url = UrlShortener.shorten(base_url)
    message = "After Dropoff at #{call.dropoff}, click here: #{url}"
    send(driver.phone, message)
  end
end

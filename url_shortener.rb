class UrlShortener
  def self.shorten(url)
    bit = Bitly.client
    short = bit.shorten(url)
    short.short_url
  end
end

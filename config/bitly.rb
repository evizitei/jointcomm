require 'bitly'

Bitly.use_api_version_3
Bitly.configure do |config|
  config.api_version = 3
  config.access_token = "ad4776e1209a07b89706169396d1ca33db4782e6"
end

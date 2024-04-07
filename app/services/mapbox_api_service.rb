require 'uri'
require 'net/http'
require 'securerandom'

# A wrapper to make http get requests to Mapbox API
class MapboxApiService
  attr_reader :url

  def initialize
    @url = URI(ENV['MAPBOX_API_URL'])
  end

  # Make a http get request
  #
  # @param [Hash] search parameters
  def http_get(params)
    all_params = params.merge(tokens)
    url.query = URI.encode_www_form(all_params)

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    request = Net::HTTP::Get.new(url)

    http.request(request)
  end

  private

  def tokens
    {
      'access_token' => ENV['MAPBOX_API_ACCESS_TOKEN'],
      'session_token' => uuid
    }
  end

  def uuid
    SecureRandom.uuid
  end
end

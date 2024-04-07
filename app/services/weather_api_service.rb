require 'uri'
require 'net/http'

# A wrapper to make http get requests to Weather API
class WeatherApiService
  attr_reader :url

  def initialize
    @url = URI(ENV['WEATHER_API_URL'])
  end

  # Make a http get request
  #
  # @param [Hash] search parameters
  def http_get(params)
    url.query = URI.encode_www_form(params.merge(days: 3))

    request = Net::HTTP::Get.new(url)
    request['X-RapidAPI-Key'] = ENV['WEATHER_API_KEY']
    request['X-RapidAPI-Host'] = ENV['WEATHER_API_HOST']

    http.request(request)
  end

  private

  def http
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http
  end
end

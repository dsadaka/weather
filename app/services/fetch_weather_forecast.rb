require 'dry/monads'

# A service object that makes an api get request with the entered search term
# to get weather details
class FetchWeatherForecast < ApplicationService
  include Dry::Monads[:result, :do]
  include Dry::Monads[:try]
  attr_reader :zip_code, :location, :search_term

  def initialize(params)
    @zip_code = params[:zip_code].presence
    @location = params[:location].presence

    # prioritize zip code over general location
    @search_term = zip_code || location
  end

  # Make a http get request to Mapbox Api
  #
  # @return [Dry::Monads::Try::Value] the data when api call is successful
  #         or [Dry::Monads::Try::Error] the error
  def call
    Try do
      raise Errors::WeatherApiServiceError, 'Required param is missing' if zip_code.blank? && location.blank?

      # check if cached data exists for zip code
      cached_data = fetch_cached_results
      return Success(cached_data) unless cached_data.nil?

      # make api call to Weather Api
      res = api.http_get({ 'q' => search_term })

      raise Errors::WeatherApiServiceError, "Error fetching weather forecast for '#{zip_code}'" unless res.code == '200'

      # serialize the required forecast data
      data = Api::WeatherForecastPresenter.new(res.body).as_json

      # cache data to limit calls to external API
      cache_results(data)

      data
    end
  end

  private

  def cache_results(data)
    Rails.cache.write(zip_code, data.merge(cached: true), expires_in: 30.minutes) if zip_code
  end

  def fetch_cached_results
    Rails.cache.read(zip_code) if zip_code
  end

  def api
    @api ||= WeatherApiService.new
  end
end

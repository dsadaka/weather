require 'dry/monads'

# A service object that makes an api get request with the entered search term
# to fetch suggested addresses
class FetchSuggestedAddresses < ApplicationService
  include Dry::Monads[:try]
  attr_reader :search_term

  def initialize(search_term)
    @search_term = search_term.to_s
  end

  # Make a http get request to Mapbox Api
  #
  # @return [Dry::Monads::Try::Value] the data when api call is successful
  #         or [Dry::Monads::Try::Error] the error
  def call
    Try do
      res = api.http_get({ 'q' => search_term })
      raise Errors::MapboxApiServiceError, 'Error fetching address suggestions' unless res.code == '200'

      res.body
    end
  end

  private

  def api
    @api ||= MapboxApiService.new
  end
end

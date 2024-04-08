class ForecastsController < ApplicationController
  def show
    return unless zip_code || search_term

    res = FetchWeatherForecast.call(service_params)

    if res.success?
      @results = res.value!
    else
      redirect_to forecast_path, flash: { error: res.exception }
    end
  end

  # GET /forecast/autocomplete?search_term=<ADDRESS>
  # This action is called via JS code when the user begins typing a search term
  # Passed: search term entered by user
  # Returns:  JSON to populate the suggested addresses dropdown
  def autocomplete
    res = FetchSuggestedAddresses.call(search_term)
    data = res.success? ? res.value! : {}
    render json: data
  end

  private

  def search_params
    params.permit(:search_term, :zip_code)
  end

  def search_term
    search_params['search_term'].presence
  end

  def zip_code
    search_params['zip_code'].presence
  end

  def service_params
    p = {}
    p[:zip_code] = zip_code if zip_code
    p[:location] = search_term if search_term
    p
  end
end

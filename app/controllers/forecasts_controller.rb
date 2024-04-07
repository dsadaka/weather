class ForecastsController < ApplicationController
  def show
    return unless zip_code || search_term

    res = FetchWeatherForecast.call(service_params)

    if res.success?
      @results = res.value!
    else
      redirect_to root_path, flash: { error: res.exception }
    end
  end

  # GET /search/autocomplete?search_term=<ADDRESS>
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

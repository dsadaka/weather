require 'rails_helper'

RSpec.describe 'Forecasts', type: :request do
  let(:zip_code) { %w[123 x1y2].sample }
  let(:service) { double }

  describe 'GET /forecast' do
    context 'when zip_code param is missing' do
      it 'does not make api service call' do
        expect(FetchWeatherForecast).not_to receive(:new)

        get forecast_path

        expect(response.status).to eq(200)
        expect(flash[:error]).to be_nil
      end
    end

    context 'when api service call fails' do
      it 'redirects to search page with error message' do
        expect(FetchWeatherForecast).to receive(:new)
          .with({ zip_code: zip_code }).and_return(service)

        res = double(success?: false, exception: { class: 'ErrorClass', message: 'ErrorMessage' })
        expect(service).to receive(:call).and_return(res)

        get forecast_path, params: { zip_code: zip_code }

        expect(response.status).to eq(302)
        expect(response).to redirect_to(forecast_path)
        expect(flash[:error]).to be_present
      end
    end

    context 'when api service call is successful' do
      let(:api_response) { File.read('spec/fixtures/api_response.json') }

      it 'displays the data' do
        expect(FetchWeatherForecast).to receive(:new)
          .with({ zip_code: zip_code }).and_return(service)

        data = {
          name: 'San Francisco',
          region: 'California',
          country: 'USA',
          current_weather: {
            temp_c: 10,
            temp_f: 60,
            condition: 'Foggy',
            icon: 'https://cdn.weatherapi.com/weather/64x64/day/113.png'
          },
          forecasted_weather: { forecasts: JSON.parse(api_response)['forecast']['forecastday'] }
        }
        res = double(success?: true, value!: data)
        expect(service).to receive(:call).and_return(res)

        get forecast_path, params: { zip_code: zip_code }

        expect(response.status).to eq(200)
        expect(flash[:error]).to be_nil
      end
    end
  end

  describe 'GET /forecast/autocomplete' do
    before do
      expect(FetchSuggestedAddresses).to receive(:new).with(zip_code).and_return(service)
    end

    context 'when api service call succeeds' do
      it 'renders data' do
        results = double(success?: true, value!: '{ "suggestions": []}')
        expect(service).to receive(:call).once.and_return(results)

        get autocomplete_forecast_path, params: { search_term: zip_code }
        json = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(json['suggestions']).not_to be_nil
      end
    end

    context 'when api service call fails' do
      it 'renders no data' do
        results = double(success?: false)
        expect(service).to receive(:call).once.and_return(results)

        get autocomplete_forecast_path, params: { search_term: zip_code }
        json = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(json['suggestions']).to be_nil
      end
    end
  end
end

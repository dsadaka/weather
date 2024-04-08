require 'rails_helper'

RSpec.describe FetchWeatherForecast do
  let(:zip_code) { %w[123 456].sample }
  let(:api_response) { File.read('spec/fixtures/api_response.json') }
  let(:forecast_data) do
    {
      name: 'Dublin',
      region: 'California',
      country: 'USA',
      current_weather: {
        condition: 'Sunny',
        icon: 'https://cdn.weatherapi.com/weather/64x64/day/113.png',
        temp_c: 26.1,
        temp_f: 79
      },
      forecasted_weather: { forecasts: JSON.parse(api_response)['forecast']['forecastday'] }
    }
  end

  it { expect(described_class).to be < ApplicationService }

  describe '.call' do
    context 'when params are missing' do
      it 'returns a WeatherApiServiceError exception' do
        params = { zip_code: nil, locaton: nil }
        res = described_class.call(params)

        expect(res).to be_failure
        expect(res.exception.class).to eq(Errors::WeatherApiServiceError)
        expect(res.exception.message).to eq('Required param is missing')
      end
    end

    context 'when cached data is found' do
      it 'returns the cached data' do
        expect(Rails.cache).to receive(:read).with(zip_code).and_return(forecast_data)
        expect(Rails.cache).not_to receive(:write)

        expect_any_instance_of(WeatherApiService).not_to receive(:http_get)

        params = { zip_code: zip_code, locaton: nil }
        res = described_class.call(params)

        expect(res).to be_success
        expect(res.value!).to eq(forecast_data)
      end
    end

    context 'when WeatherApiService call succeeds' do
      context 'with zip_code param' do
        it 'caches and returns data' do
          expect(Rails.cache).to receive(:read).with(zip_code).and_return(nil)

          expect_any_instance_of(WeatherApiService).to receive(:http_get)
            .with({ 'q' => zip_code })
            .and_return(double(code: '200', body: api_response))

          expect_any_instance_of(Api::WeatherForecastPresenter).to receive(:as_json).and_call_original

          expect(Rails.cache).to receive(:write)
            .with(zip_code.to_s, forecast_data.merge(cached: true), expires_in: 30.minutes).once

          params = { zip_code: zip_code, location: nil }
          res = described_class.call(params)

          expect(res).to be_success
          expect(res.value!).to eq(forecast_data)
        end
      end

      context 'with location param' do
        it 'returns data' do
          expect(Rails.cache).not_to receive(:read)
          expect(Rails.cache).not_to receive(:write)

          expect_any_instance_of(WeatherApiService).to receive(:http_get)
            .with({ 'q' => 'Dublin, CA' })
            .and_return(double(code: '200', body: api_response))

          expect_any_instance_of(Api::WeatherForecastPresenter).to receive(:as_json).and_call_original

          params = { zip_code: '', location: 'Dublin, CA' }
          res = described_class.call(params)

          expect(res).to be_success
          expect(res.value!).to eq(forecast_data)
        end
      end
    end

    context 'when WeatherApiService call fails' do
      it 'returns a WeatherApiServiceError exception' do
        expect_any_instance_of(WeatherApiService).to receive(:http_get)
          .with({ 'q' => zip_code.to_s })
          .and_return(double(code: '400'))

        params = { zip_code: zip_code, location: nil }
        res = described_class.call(params)

        expect(res).to be_failure
        expect(res.exception.class).to eq(Errors::WeatherApiServiceError)
        expect(res.exception.message).to eq("Error fetching weather forecast for '#{zip_code}'")
      end
    end
  end
end

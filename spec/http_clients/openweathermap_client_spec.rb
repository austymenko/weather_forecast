# frozen_string_literal: true

require 'rails_helper'

describe OpenweathermapClient do
  let(:longitude) { -79.718903 }
  let(:latitude) { 43.570816 }
  let(:wrong_api_key) { 'wrong app id' }

  describe '.run' do
    context 'when requesting current weather' do
      context 'with invalid authentication' do
        before do
          allow_any_instance_of(described_class)
            .to receive(:api_key).and_return(wrong_api_key)
        end

        let(:unauthorized_result) do
          VCR.use_cassette('openweathermap_client_401') do
            OpenweathermapClient.run(lon: longitude, lat: latitude)
          end
        end

        it 'returns unauthorized error' do
          expect(unauthorized_result.valid?).to be_falsy
          expect(unauthorized_result.errors.messages)
            .to eq(mapbox_client_error: ['the server responded with status 401'])
        end
      end

      context 'with valid authentication' do
        let(:weather_result) do
          VCR.use_cassette('openweathermap_client_200') do
            OpenweathermapClient.run(lon: longitude, lat: latitude)
          end
        end

        it 'returns current weather data' do
          expect(weather_result.valid?).to be_truthy
          expect(weather_result.result).to be_a(Hash)
          expect(weather_result.result).to eq(expected_current_weather_hash_response)
        end
      end
    end

    context 'when requesting forecast' do
      context 'with invalid authentication' do
        before do
          allow_any_instance_of(described_class)
            .to receive(:api_key).and_return(wrong_api_key)
        end

        let(:unauthorized_result) do
          VCR.use_cassette('openweathermap_client_forecast_401') do
            OpenweathermapClient.run(lon: longitude, lat: latitude)
          end
        end

        it 'returns unauthorized error' do
          expect(unauthorized_result.valid?).to be_falsy
          expect(unauthorized_result.errors.messages)
            .to eq(mapbox_client_error: ['the server responded with status 401'])
        end
      end

      context 'with valid authentication' do
        let(:forecast_result) do
          VCR.use_cassette('openweathermap_client_forecast_200') do
            OpenweathermapClient.run(
              lon: longitude,
              lat: latitude,
              current_weather: false
            )
          end
        end

        let(:forecast_data) do
          forecast_result.result['list'].map do |entry|
            {
              weather: entry['weather'],
              dt_txt: entry['dt_txt']
            }
          end
        end

        it 'returns forecast data' do
          expect(forecast_result.valid?).to be_truthy
          expect(forecast_data).to eq(expected_forecast)
        end
      end
    end
  end

  private

  def expected_current_weather_hash_response
    {
      'coord' => {
        'lon' => -79.7189,
        'lat' => 43.5708
      },
      'weather' => [
        {
          'id' => 803,
          'main' => 'Clouds',
          'description' => 'broken clouds',
          'icon' => '04d'
        }
      ],
      'base' => 'stations',
      'main' => {
        'temp' => 4.74,
        'feels_like' => -0.07,
        'temp_min' => 4.09,
        'temp_max' => 5.62,
        'pressure' => 1007,
        'humidity' => 59,
        'sea_level' => 1007,
        'grnd_level' => 986
      },
      'visibility' => 10_000,
      'wind' => {
        'speed' => 7.72,
        'deg' => 310,
        'gust' => 11.32
      },
      'clouds' => {
        'all' => 75
      },
      'dt' => 1_732_822_782,
      'sys' => {
        'type' => 2,
        'id' => 2_020_569,
        'country' => 'CA',
        'sunrise' => 1_732_796_974,
        'sunset' => 1_732_830_292
      },
      'timezone' => -18_000,
      'id' => 6_174_528,
      'name' => 'Vista Heights',
      'cod' => 200
    }
  end

  def expected_forecast
    [{ weather: [{ 'id' => 803, 'main' => 'Clouds', 'description' => 'broken clouds', 'icon' => '04d' }], dt_txt: '2024-11-28 21:00:00' },
     { weather: [{ 'id' => 803, 'main' => 'Clouds', 'description' => 'broken clouds', 'icon' => '04n' }],
       dt_txt: '2024-11-29 00:00:00' },
     { weather: [{ 'id' => 802, 'main' => 'Clouds', 'description' => 'scattered clouds', 'icon' => '03n' }],
       dt_txt: '2024-11-29 03:00:00' },
     { weather: [{ 'id' => 802, 'main' => 'Clouds', 'description' => 'scattered clouds', 'icon' => '03n' }],
       dt_txt: '2024-11-29 06:00:00' },
     { weather: [{ 'id' => 804, 'main' => 'Clouds', 'description' => 'overcast clouds', 'icon' => '04n' }],
       dt_txt: '2024-11-29 09:00:00' },
     { weather: [{ 'id' => 804, 'main' => 'Clouds', 'description' => 'overcast clouds', 'icon' => '04n' }],
       dt_txt: '2024-11-29 12:00:00' },
     { weather: [{ 'id' => 804, 'main' => 'Clouds', 'description' => 'overcast clouds', 'icon' => '04d' }],
       dt_txt: '2024-11-29 15:00:00' },
     { weather: [{ 'id' => 804, 'main' => 'Clouds', 'description' => 'overcast clouds', 'icon' => '04d' }],
       dt_txt: '2024-11-29 18:00:00' },
     { weather: [{ 'id' => 804, 'main' => 'Clouds', 'description' => 'overcast clouds', 'icon' => '04d' }],
       dt_txt: '2024-11-29 21:00:00' },
     { weather: [{ 'id' => 804, 'main' => 'Clouds', 'description' => 'overcast clouds', 'icon' => '04n' }],
       dt_txt: '2024-11-30 00:00:00' },
     { weather: [{ 'id' => 804, 'main' => 'Clouds', 'description' => 'overcast clouds', 'icon' => '04n' }],
       dt_txt: '2024-11-30 03:00:00' },
     { weather: [{ 'id' => 804, 'main' => 'Clouds', 'description' => 'overcast clouds', 'icon' => '04n' }],
       dt_txt: '2024-11-30 06:00:00' },
     { weather: [{ 'id' => 804, 'main' => 'Clouds', 'description' => 'overcast clouds', 'icon' => '04n' }],
       dt_txt: '2024-11-30 09:00:00' },
     { weather: [{ 'id' => 804, 'main' => 'Clouds', 'description' => 'overcast clouds', 'icon' => '04n' }],
       dt_txt: '2024-11-30 12:00:00' },
     { weather: [{ 'id' => 804, 'main' => 'Clouds', 'description' => 'overcast clouds', 'icon' => '04d' }],
       dt_txt: '2024-11-30 15:00:00' },
     { weather: [{ 'id' => 804, 'main' => 'Clouds', 'description' => 'overcast clouds', 'icon' => '04d' }],
       dt_txt: '2024-11-30 18:00:00' },
     { weather: [{ 'id' => 804, 'main' => 'Clouds', 'description' => 'overcast clouds', 'icon' => '04d' }],
       dt_txt: '2024-11-30 21:00:00' },
     { weather: [{ 'id' => 804, 'main' => 'Clouds', 'description' => 'overcast clouds', 'icon' => '04n' }],
       dt_txt: '2024-12-01 00:00:00' },
     { weather: [{ 'id' => 804, 'main' => 'Clouds', 'description' => 'overcast clouds', 'icon' => '04n' }],
       dt_txt: '2024-12-01 03:00:00' },
     { weather: [{ 'id' => 804, 'main' => 'Clouds', 'description' => 'overcast clouds', 'icon' => '04n' }],
       dt_txt: '2024-12-01 06:00:00' },
     { weather: [{ 'id' => 804, 'main' => 'Clouds', 'description' => 'overcast clouds', 'icon' => '04n' }],
       dt_txt: '2024-12-01 09:00:00' },
     { weather: [{ 'id' => 804, 'main' => 'Clouds', 'description' => 'overcast clouds', 'icon' => '04n' }],
       dt_txt: '2024-12-01 12:00:00' },
     { weather: [{ 'id' => 804, 'main' => 'Clouds', 'description' => 'overcast clouds', 'icon' => '04d' }],
       dt_txt: '2024-12-01 15:00:00' },
     { weather: [{ 'id' => 500, 'main' => 'Rain', 'description' => 'light rain', 'icon' => '10d' }],
       dt_txt: '2024-12-01 18:00:00' },
     { weather: [{ 'id' => 601, 'main' => 'Snow', 'description' => 'snow', 'icon' => '13d' }],
       dt_txt: '2024-12-01 21:00:00' },
     { weather: [{ 'id' => 600, 'main' => 'Snow', 'description' => 'light snow', 'icon' => '13n' }],
       dt_txt: '2024-12-02 00:00:00' },
     { weather: [{ 'id' => 804, 'main' => 'Clouds', 'description' => 'overcast clouds', 'icon' => '04n' }],
       dt_txt: '2024-12-02 03:00:00' },
     { weather: [{ 'id' => 803, 'main' => 'Clouds', 'description' => 'broken clouds', 'icon' => '04n' }],
       dt_txt: '2024-12-02 06:00:00' },
     { weather: [{ 'id' => 803, 'main' => 'Clouds', 'description' => 'broken clouds', 'icon' => '04n' }],
       dt_txt: '2024-12-02 09:00:00' },
     { weather: [{ 'id' => 803, 'main' => 'Clouds', 'description' => 'broken clouds', 'icon' => '04n' }],
       dt_txt: '2024-12-02 12:00:00' },
     { weather: [{ 'id' => 803, 'main' => 'Clouds', 'description' => 'broken clouds', 'icon' => '04d' }],
       dt_txt: '2024-12-02 15:00:00' },
     { weather: [{ 'id' => 803, 'main' => 'Clouds', 'description' => 'broken clouds', 'icon' => '04d' }],
       dt_txt: '2024-12-02 18:00:00' },
     { weather: [{ 'id' => 803, 'main' => 'Clouds', 'description' => 'broken clouds', 'icon' => '04d' }],
       dt_txt: '2024-12-02 21:00:00' },
     { weather: [{ 'id' => 802, 'main' => 'Clouds', 'description' => 'scattered clouds', 'icon' => '03n' }],
       dt_txt: '2024-12-03 00:00:00' },
     { weather: [{ 'id' => 803, 'main' => 'Clouds', 'description' => 'broken clouds', 'icon' => '04n' }],
       dt_txt: '2024-12-03 03:00:00' },
     { weather: [{ 'id' => 802, 'main' => 'Clouds', 'description' => 'scattered clouds', 'icon' => '03n' }],
       dt_txt: '2024-12-03 06:00:00' },
     { weather: [{ 'id' => 803, 'main' => 'Clouds', 'description' => 'broken clouds', 'icon' => '04n' }],
       dt_txt: '2024-12-03 09:00:00' },
     { weather: [{ 'id' => 803, 'main' => 'Clouds', 'description' => 'broken clouds', 'icon' => '04n' }],
       dt_txt: '2024-12-03 12:00:00' },
     { weather: [{ 'id' => 803, 'main' => 'Clouds', 'description' => 'broken clouds', 'icon' => '04d' }],
       dt_txt: '2024-12-03 15:00:00' },
     { weather: [{ 'id' => 803, 'main' => 'Clouds', 'description' => 'broken clouds', 'icon' => '04d' }],
       dt_txt: '2024-12-03 18:00:00' }]
  end
end

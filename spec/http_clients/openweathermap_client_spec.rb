# frozen_string_literal: true

require 'rails_helper'

describe OpenweathermapClient do
  context 'current weather' do
    it 'has 401 UnauthorizedError in response' do
      allow_any_instance_of(described_class)
        .to receive(:api_key).and_return('wrong app id')

      outcome = nil

      VCR.use_cassette('openweathermap_client_401') do
        outcome = OpenweathermapClient.run(
          lon: -79.718903,
          lat: -43.570816
        )
      end

      expect(outcome.valid?).to be_falsy
      expect(outcome.errors.messages)
        .to eq(
          { mapbox_client_error: ['the server responded with status 401'] }
        )
    end

    it 'has valid response with the current weather data' do
      outcome = nil

      VCR.use_cassette('openweathermap_client_200') do
        outcome = OpenweathermapClient.run(
          lon: -79.718903,
          lat: 43.570816
        )
      end

      response_hash = outcome.result

      expect(outcome.valid?).to be_truthy
      expect(response_hash.class).to eq(Hash)
      expect(response_hash).to eq(expected_current_weather_hash_response)
    end
  end

  context 'forecast' do
    it 'has 401 UnauthorizedError in response' do
      allow_any_instance_of(described_class)
        .to receive(:api_key).and_return('wrong app id')

      outcome = nil

      VCR.use_cassette('openweathermap_client_forecast_401') do
        outcome = OpenweathermapClient.run(
          lon: -79.718903,
          lat: -43.570816
        )
      end

      expect(outcome.valid?).to be_falsy
      expect(outcome.errors.messages)
        .to eq(
          { mapbox_client_error: ['the server responded with status 401'] }
        )
    end

    it 'has valid response with the forecast data' do
      outcome = nil

      VCR.use_cassette('openweathermap_client_forecast_200') do
        outcome = OpenweathermapClient.run(
          lon: -79.718903,
          lat: 43.570816,
          current_weather: false
        )
      end

      response_hash = outcome.result
      forecast_data = response_hash['list'].map do |entry|
        {
          weather: entry['weather'],
          dt_txt: entry['dt_txt']
        }
      end

      expect(outcome.valid?).to be_truthy
      expect(forecast_data).to eq(expected_forecast)
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

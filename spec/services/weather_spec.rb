# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WeatherService do
  let(:country) { 'United States' }
  let(:postcode) { '12345' }
  let(:lat) { 40.7128 }
  let(:lon) { -74.0060 }
  let(:redis_weather_key_ttl) { 1800 }
  let(:current_weather) { true }

  # base parameters for testing the weather service
  let(:base_params) do
    {
      country: country,
      postcode: postcode,
      lat: lat,
      lon: lon,
      redis_weather_key_ttl: redis_weather_key_ttl,
      current_weather: current_weather
    }
  end

  # sample response for current weather
  let(:mock_weather_data) do
    {
      'temperature' => 20.5,
      'humidity' => 65,
      'wind_speed' => 5.2
    }
  end

  # sample response for forecast data
  let(:mock_forecast_data) do
    [
      { 'temperature' => 20.5, 'date' => '2024-03-01' },
      { 'temperature' => 22.0, 'date' => '2024-03-02' }
    ]
  end

  let(:mock_provider) { instance_double('WeatherProviders::Base') }
  let(:mock_provider_outcome) { instance_double('ActiveInteraction::Outcome', result: mock_weather_data) }

  before do
    allow(WeatherProviders::Factory).to receive(:for).with(:openweathermap).and_return(mock_provider)
    allow(mock_provider).to receive(:fetch_weather).and_return(mock_provider_outcome)
    allow(RedisCacheService).to receive(:fetch).and_yield.and_return(mock_weather_data)
    allow(RedisCacheService).to receive(:age).and_return(0)
  end

  describe '#execute' do
    context 'when fetching current weather' do
      it 'returns weather data with symbolized keys' do
        result = described_class.run!(base_params)
        expect(result[:weather_data]).to include(
          temperature: 20.5,
          humidity: 65,
          wind_speed: 5.2
        )
      end

      it 'includes cache age in the response' do
        allow(RedisCacheService).to receive(:age).and_return(300)
        result = described_class.run!(base_params)
        expect(result[:cache_age]).to eq(300)
      end

      it 'uses correct Redis key format' do
        expect(RedisCacheService).to receive(:fetch)
          .with('current_weather:united-states:12345', ttl: redis_weather_key_ttl)

        described_class.run!(base_params)
      end
    end

    context 'when fetching forecast weather' do
      let(:current_weather) { false }

      before do
        allow(mock_provider_outcome).to receive(:result).and_return(mock_forecast_data)
        allow(RedisCacheService).to receive(:fetch).and_yield.and_return(mock_forecast_data)
      end

      it 'returns an array of forecast data with symbolized keys' do
        result = described_class.run!(base_params)
        expect(result[:weather_data]).to be_an(Array)
        expect(result[:weather_data].first).to include(
          temperature: 20.5,
          date: '2024-03-01'
        )
      end

      it 'uses correct Redis key format for forecast' do
        expect(RedisCacheService).to receive(:fetch)
          .with('forecast:united-states:12345', ttl: redis_weather_key_ttl)

        described_class.run!(base_params)
      end
    end

    context 'with various input formats' do
      it 'handles postal codes with spaces' do
        expect(RedisCacheService).to receive(:fetch)
          .with('current_weather:united-states:12-345', ttl: redis_weather_key_ttl)

        described_class.run!(base_params.merge(postcode: ' 12 345 '))
      end

      it 'handles country names with spaces' do
        expect(RedisCacheService).to receive(:fetch)
          .with('current_weather:united-states:12345', ttl: redis_weather_key_ttl)

        described_class.run!(base_params.merge(country: ' United  States '))
      end
    end

    context 'error handling' do
      it 'adds an error when weather provider raises an exception' do
        allow(mock_provider).to receive(:fetch_weather).and_raise(StandardError.new('API Error'))
        allow(RedisCacheService).to receive(:fetch).and_raise(StandardError.new('API Error'))

        outcome = described_class.run(base_params)
        expect(outcome.errors[:weather_service_error]).to include('API Error')
      end

      it 'adds an error when Redis service raises an exception' do
        allow(RedisCacheService).to receive(:fetch).and_raise(StandardError.new('Redis Error'))

        outcome = described_class.run(base_params)
        expect(outcome.errors[:weather_service_error]).to include('Redis Error')
      end
    end

    context 'weather provider configuration' do
      before do
        # clear cached provider to test factory interactions
        allow_any_instance_of(described_class).to receive(:instance_variable_get).with(:@weather_provider).and_return(nil)
      end

      it 'uses the default weather provider' do
        expect(WeatherProviders::Factory).to receive(:for).with(:openweathermap).and_return(mock_provider)
        described_class.run!(base_params)
      end

      it 'passes correct parameters to weather provider' do
        new_provider = instance_double('WeatherProviders::Base')
        allow(WeatherProviders::Factory).to receive(:for).with(:openweathermap).and_return(new_provider)
        expect(new_provider).to receive(:fetch_weather).with(
          lat: lat,
          lon: lon,
          current_weather: current_weather
        ).and_return(mock_provider_outcome)

        described_class.run!(base_params)
      end
    end
  end
end

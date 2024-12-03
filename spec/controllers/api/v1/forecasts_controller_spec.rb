# frozen_string_literal: true

require 'rails_helper'
require 'active_interaction'

RSpec.describe Api::V1::ForecastsController, type: :controller do
  render_views

  let(:latitude) { '40.7128' }
  let(:longitude) { '-74.0060' }
  let(:country) { 'United States' }
  let(:postcode) { '10001' }
  let(:address) { '123 Main St' }

  let(:base_params) do
    {
      latitude: latitude,
      longitude: longitude,
      country: country,
      postcode: postcode,
      address: address
    }
  end

  let(:weather_service_result) do
    {
      weather_data: weather_data,
      cache_age: cache_age
    }
  end

  let(:weather_data) do
    {
      temp: 25,
      humidity: 65,
      wind_speed: 5
    }
  end

  let(:cache_age) { 300 }

  let(:weather_service_outcome) do
    double('WeatherServiceOutcome', valid?: true, result: weather_service_result)
  end

  let(:turbo_stream_response) do
    "<turbo-stream action='replace' target='weather-data'>mock content</turbo-stream>"
  end

  describe '#current_weather' do
    before do
      allow(WeatherService).to receive(:run).and_return(weather_service_outcome)
      allow(controller).to receive(:success_streams).and_return([turbo_stream_response])
      request.accept = 'text/vnd.turbo-stream.html'
    end

    it 'calls WeatherService with correct parameters' do
      expect(WeatherService).to receive(:run).with(
        country: country,
        postcode: postcode,
        lat: latitude.to_f,
        lon: longitude.to_f,
        current_weather: true
      )

      get :current_weather, params: base_params, format: :turbo_stream
    end

    it 'renders turbo stream response' do
      get :current_weather, params: base_params, format: :turbo_stream
      expect(response.media_type).to eq Mime[:turbo_stream]
    end

    it 'includes success streams in response' do
      expect(controller).to receive(:success_streams).with(weather_data, cache_age).and_return([turbo_stream_response])
      get :current_weather, params: base_params, format: :turbo_stream
    end

    context 'with missing parameters' do
      it 'handles missing latitude' do
        base_params.delete(:latitude)
        get :current_weather, params: base_params, format: :turbo_stream
        expect(response).to have_http_status(:success)
      end

      it 'handles missing longitude' do
        base_params.delete(:longitude)
        get :current_weather, params: base_params, format: :turbo_stream
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe '#forecast' do
    before do
      allow(WeatherService).to receive(:run).and_return(weather_service_outcome)
      allow(controller).to receive(:success_streams).and_return([turbo_stream_response])
      request.accept = 'text/vnd.turbo-stream.html'
    end

    it 'calls WeatherService with correct parameters' do
      expect(WeatherService).to receive(:run).with(
        country: country,
        postcode: postcode,
        lat: latitude.to_f,
        lon: longitude.to_f,
        current_weather: false
      )

      get :forecast, params: base_params, format: :turbo_stream
    end

    it 'renders turbo stream response' do
      get :forecast, params: base_params, format: :turbo_stream
      expect(response.media_type).to eq Mime[:turbo_stream]
    end

    it 'includes success streams in response' do
      expect(controller).to receive(:success_streams).with(weather_data, cache_age).and_return([turbo_stream_response])
      get :forecast, params: base_params, format: :turbo_stream
    end

    context 'with decimal coordinates' do
      let(:latitude) { '40.7128453' }
      let(:longitude) { '-74.0060123' }

      it 'handles decimal coordinates correctly' do
        expect(WeatherService).to receive(:run).with(
          hash_including(
            lat: 40.7128453,
            lon: -74.0060123
          )
        )

        get :forecast, params: base_params, format: :turbo_stream
      end
    end
  end

  describe 'error handling' do
    before do
      request.accept = 'text/vnd.turbo-stream.html'
      allow(controller).to receive(:success_streams).and_return([turbo_stream_response])
    end

    context 'when WeatherService fails' do
      let(:error_outcome) do
        double('WeatherServiceOutcome',
               valid?: true,
               result: { weather_data: nil, cache_age: 0 }
        )
      end

      before do
        allow(WeatherService).to receive(:run).and_return(error_outcome)
      end

      it 'handles the error gracefully' do
        get :current_weather, params: base_params, format: :turbo_stream
        expect(response).to have_http_status(:success)
      end

      it 'renders error streams' do
        expect(controller).to receive(:success_streams).with(nil, 0).and_return([turbo_stream_response])
        get :current_weather, params: base_params, format: :turbo_stream
      end
    end
  end
end
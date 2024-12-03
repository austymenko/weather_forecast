# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OpenweathermapService do
  let(:lat) { 40.7128 }
  let(:lon) { -74.0060 }
  let(:current_weather) { true }

  let(:base_params) do
    {
      lat: lat,
      lon: lon,
      current_weather: current_weather
    }
  end

  let(:current_weather_data) do
    {
      'main' => { 'temp' => 20.5, 'humidity' => 65 },
      'wind' => { 'speed' => 5.2 }
    }
  end

  let(:forecast_weather_data) do
    {
      'list' => [
        { 'main' => { 'temp' => 20.5 }, 'dt_txt' => '2024-03-01 12:00:00' },
        { 'main' => { 'temp' => 22.0 }, 'dt_txt' => '2024-03-01 15:00:00' }
      ]
    }
  end

  let(:client_outcome) { instance_double('ActiveInteraction::Outcome') }
  let(:presenter_outcome) { instance_double('ActiveInteraction::Outcome') }

  describe '#execute' do
    context 'when fetching current weather' do
      before do
        allow(OpenweathermapClient).to receive(:run).and_return(client_outcome)
        allow(OpenweathermapWeatherPresenter).to receive(:run).and_return(presenter_outcome)
      end

      context 'when successful' do
        before do
          allow(client_outcome).to receive(:valid?).and_return(true)
          allow(client_outcome).to receive(:result).and_return(current_weather_data)
          allow(presenter_outcome).to receive(:valid?).and_return(true)
          allow(presenter_outcome).to receive(:result).and_return(current_weather_data)
        end

        it 'returns processed weather data' do
          result = described_class.run!(base_params)
          expect(result).to eq(current_weather_data)
        end

        it 'calls client with correct parameters' do
          expect(OpenweathermapClient).to receive(:run).with(
            lon: lon,
            lat: lat,
            current_weather: true
          )
          described_class.run!(base_params)
        end
      end

      context 'when client fails' do
        before do
          allow(client_outcome).to receive(:valid?).and_return(false)
          allow(client_outcome).to receive(:errors).and_return(
            ActiveModel::Errors.new(OpenweathermapClient.new).tap do |errors|
              errors.add(:service_error, 'API error')
            end
          )
        end

        it 'adds client errors to service errors' do
          outcome = described_class.run(base_params)
          expect(outcome).not_to be_valid
          expect(outcome.errors.full_messages).to include('Service error API error')
        end
      end

      context 'when presenter fails' do
        before do
          allow(client_outcome).to receive(:valid?).and_return(true)
          allow(client_outcome).to receive(:result).and_return(current_weather_data)
          allow(presenter_outcome).to receive(:valid?).and_return(false)
          allow(presenter_outcome).to receive(:errors).and_return(
            ActiveModel::Errors.new(OpenweathermapWeatherPresenter.new).tap do |errors|
              errors.add(:service_error, 'Processing error')
            end
          )
        end

        it 'adds presenter errors to service errors' do
          outcome = described_class.run(base_params)
          expect(outcome).not_to be_valid
          expect(outcome.errors.full_messages).to include('Service error Processing error')
        end
      end
    end

    context 'when fetching forecast' do
      let(:current_weather) { false }

      before do
        allow(OpenweathermapClient).to receive(:run).and_return(client_outcome)
        allow(OpenweathermapForecastPresenter).to receive(:run).and_return(presenter_outcome)
      end

      context 'when successful' do
        before do
          allow(client_outcome).to receive(:valid?).and_return(true)
          allow(client_outcome).to receive(:result).and_return(forecast_weather_data)
          allow(presenter_outcome).to receive(:valid?).and_return(true)
          allow(presenter_outcome).to receive(:result).and_return(forecast_weather_data['list'])
        end

        it 'returns processed forecast data' do
          result = described_class.run!(base_params)
          expect(result).to eq(forecast_weather_data['list'])
        end

        it 'uses forecast presenter' do
          expect(OpenweathermapForecastPresenter).to receive(:run).with(
            weather_data: forecast_weather_data['list']
          )
          described_class.run!(base_params)
        end
      end
    end

    context 'coordinate validation' do
      context 'with invalid coordinates' do
        let(:invalid_params) { base_params.merge(lat: 100, lon: 200) }

        it 'validates latitude range' do
          outcome = described_class.run(invalid_params)
          expect(outcome.errors[:lat]).to be_present
        end

        it 'validates longitude range' do
          outcome = described_class.run(invalid_params)
          expect(outcome.errors[:lon]).to be_present
        end
      end

      context 'with valid coordinates' do
        it 'passes validation' do
          outcome = described_class.run(base_params)
          expect(outcome.errors[:lat]).to be_empty
          expect(outcome.errors[:lon]).to be_empty
        end
      end
    end
  end

  describe 'error processing' do
    let(:error_message) { 'Unexpected error' }

    before do
      allow(OpenweathermapClient).to receive(:run).and_raise(StandardError, error_message)
    end

    it 'handles unexpected errors' do
      outcome = described_class.run(base_params)
      expect(outcome).not_to be_valid
      expect(outcome.errors.full_messages).to include("Service error #{error_message}")
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

module WeatherProviders
  RSpec.describe OpenweathermapProvider do
    let(:lat) { 40.7128 }
    let(:lon) { -74.0060 }
    let(:current_weather) { true }
    let(:service_outcome) { instance_double('ActiveInteraction::Outcome') }

    describe '#fetch_weather' do
      before do
        allow(OpenweathermapService).to receive(:run).and_return(service_outcome)
      end

      it 'calls OpenweathermapService with correct parameters' do
        expect(OpenweathermapService).to receive(:run).with(
          lat: lat,
          lon: lon,
          current_weather: current_weather
        )

        described_class.new.fetch_weather(
          lat: lat,
          lon: lon,
          current_weather: current_weather
        )
      end

      it 'returns the service outcome directly' do
        result = described_class.new.fetch_weather(
          lat: lat,
          lon: lon,
          current_weather: current_weather
        )
        expect(result).to eq(service_outcome)
      end

      context 'when fetching current weather' do
        let(:current_weather) { true }

        it 'passes correct current_weather flag' do
          expect(OpenweathermapService).to receive(:run).with(
            lat: lat,
            lon: lon,
            current_weather: true
          )

          described_class.new.fetch_weather(
            lat: lat,
            lon: lon,
            current_weather: current_weather
          )
        end
      end

      context 'when fetching forecast' do
        let(:current_weather) { false }

        it 'passes correct current_weather flag' do
          expect(OpenweathermapService).to receive(:run).with(
            lat: lat,
            lon: lon,
            current_weather: false
          )

          described_class.new.fetch_weather(
            lat: lat,
            lon: lon,
            current_weather: current_weather
          )
        end
      end

      context 'with different coordinate values' do
        coordinates = {
          'positive values' => { lat: 51.5074, lon: 0.1278 },
          'negative values' => { lat: -33.8688, lon: -151.2093 },
          'zero values' => { lat: 0.0, lon: 0.0 },
          'decimal precision' => { lat: 35.6762, lon: 139.6503 }
        }

        coordinates.each do |desc, coords|
          it "handles #{desc}" do
            expect(OpenweathermapService).to receive(:run).with(
              lat: coords[:lat],
              lon: coords[:lon],
              current_weather: current_weather
            )

            described_class.new.fetch_weather(
              lat: coords[:lat],
              lon: coords[:lon],
              current_weather: current_weather
            )
          end
        end
      end
    end
  end
end

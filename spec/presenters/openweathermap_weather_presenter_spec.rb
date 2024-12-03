# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OpenweathermapWeatherPresenter do
  let(:current_time) { Time.new(2024, 3, 1, 12, 0, 0) }

  let(:weather_data) do
    {
      'weather' => [
        { 'icon' => '01d' }
      ],
      'main' => {
        'temp' => 25.6,
        'feels_like' => 24.8,
        'humidity' => 65
      },
      'wind' => {
        'speed' => 5.2
      }
    }
  end

  before do
    allow(Time).to receive(:current).and_return(current_time)
  end

  describe '#execute' do
    it 'formats weather data correctly' do
      result = described_class.run(weather_data: weather_data).result

      expect(result).to eq(
        {
          date: 'Mar 01, 2024',
          icon: '01d',
          title: OpenweathermapWeatherPresenter::WEATHER_STATUS_MAPPING['01d'],
          temp: 25,
          feels_like: 24,
          humidity: 65,
          wind_speed: 5
        }
      )
    end

    context 'with empty weather data' do
      let(:weather_data) { {} }

      it 'handles empty data gracefully' do
        result = described_class.run(weather_data: weather_data).result

        expect(result).to eq(
          {
            date: 'Mar 01, 2024',
            icon: nil,
            title: nil,
            temp: 0,
            feels_like: 0,
            humidity: 0,
            wind_speed: 0
          }
        )
      end
    end

    context 'with missing nested data' do
      let(:weather_data) do
        {
          'weather' => [],
          'main' => {},
          'wind' => {}
        }
      end

      it 'handles missing nested data gracefully' do
        result = described_class.run(weather_data: weather_data).result

        expect(result).to eq(
          {
            date: 'Mar 01, 2024',
            icon: nil,
            title: nil,
            temp: 0,
            feels_like: 0,
            humidity: 0,
            wind_speed: 0
          }
        )
      end
    end

    context 'with decimal values' do
      let(:weather_data) do
        {
          'weather' => [{ 'icon' => '01d' }],
          'main' => {
            'temp' => 25.6,
            'feels_like' => 24.8,
            'humidity' => 65.7
          },
          'wind' => {
            'speed' => 5.2
          }
        }
      end

      it 'converts numerical values to integers' do
        result = described_class.run(weather_data: weather_data).result

        expect(result[:temp]).to eq(25)
        expect(result[:feels_like]).to eq(24)
        expect(result[:humidity]).to eq(65)
        expect(result[:wind_speed]).to eq(5)
      end
    end

    context 'with nil values' do
      let(:weather_data) do
        {
          'weather' => [{ 'icon' => nil }],
          'main' => {
            'temp' => nil,
            'feels_like' => nil,
            'humidity' => nil
          },
          'wind' => {
            'speed' => nil
          }
        }
      end

      it 'handles nil values gracefully' do
        result = described_class.run(weather_data: weather_data).result

        expect(result).to include(
          icon: nil,
          title: nil,
          temp: 0,
          feels_like: 0,
          humidity: 0,
          wind_speed: 0
        )
      end
    end

    context 'with different weather icons' do
      weather_conditions = {
        '01d' => 'clear',
        '02d' => 'partly_cloudy',
        '03d' => 'cloudy',
        '04d' => 'cloudy' # Updated to match actual mapping
      }

      weather_conditions.each do |icon, title|
        context "with #{icon} icon" do
          let(:weather_data) do
            {
              'weather' => [{ 'icon' => icon }],
              'main' => { 'temp' => 20 },
              'wind' => { 'speed' => 5 }
            }
          end

          it "returns correct title for #{icon}" do
            result = described_class.run(weather_data: weather_data).result
            expect(result[:icon]).to eq(icon)
            expect(result[:title]).to eq(title)
          end
        end
      end
    end
  end
end

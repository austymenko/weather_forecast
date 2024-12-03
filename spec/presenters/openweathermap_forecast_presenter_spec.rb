# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OpenweathermapForecastPresenter do
  let(:timestamp1) { Time.new(2024, 3, 1, 12, 0, 0).to_i }
  let(:timestamp2) { Time.new(2024, 3, 1, 15, 0, 0).to_i }
  let(:timestamp3) { Time.new(2024, 3, 2, 12, 0, 0).to_i }

  let(:weather_data) do
    [
      {
        'dt' => timestamp1,
        'main' => {
          'temp_max' => 25.6,
          'temp_min' => 20.3,
          'humidity' => 65
        },
        'wind' => {
          'speed' => 5.2
        },
        'weather' => [
          { 'icon' => '01d' }
        ]
      },
      {
        'dt' => timestamp2,
        'main' => {
          'temp_max' => 27.8,
          'temp_min' => 19.5,
          'humidity' => 70
        },
        'wind' => {
          'speed' => 6.1
        },
        'weather' => [
          { 'icon' => '01d' }
        ]
      },
      {
        'dt' => timestamp3,
        'main' => {
          'temp_max' => 24.2,
          'temp_min' => 18.9,
          'humidity' => 75
        },
        'wind' => {
          'speed' => 4.8
        },
        'weather' => [
          { 'icon' => '02d' }
        ]
      }
    ]
  end

  describe '#execute' do
    it 'groups and formats forecast data by date' do
      result = described_class.run(weather_data: weather_data).result

      expect(result).to contain_exactly(
        {
          date: 'Mar 01, 2024',
          max_temp: 28,
          min_temp: 20,
          humidity: 67, # Average of 65 and 70 rounded = 67
          wind_speed: 6,
          most_common_icon: '01d',
          title: OpenweathermapForecastPresenter::WEATHER_STATUS_MAPPING['01d']
        },
        {
          date: 'Mar 02, 2024',
          max_temp: 24,
          min_temp: 19,
          humidity: 75,
          wind_speed: 5,
          most_common_icon: '02d',
          title: OpenweathermapForecastPresenter::WEATHER_STATUS_MAPPING['02d']
        }
      )
    end

    context 'with empty weather data' do
      let(:weather_data) { [] }

      it 'returns empty array' do
        result = described_class.run(weather_data: weather_data).result
        expect(result).to be_empty
      end
    end

    context 'with nil values' do
      let(:weather_data) do
        [
          {
            'dt' => timestamp1,
            'main' => {
              'temp_max' => nil,
              'temp_min' => nil,
              'humidity' => nil
            },
            'wind' => {
              'speed' => nil
            },
            'weather' => nil
          }
        ]
      end

      it 'handles nil values gracefully' do
        expect { described_class.run(weather_data: weather_data) }.not_to raise_error
      end
    end

    context 'with missing weather data' do
      let(:weather_data) do
        [
          {
            'dt' => timestamp1,
            'main' => {
              'temp_max' => 25.6
            }
          }
        ]
      end

      it 'handles missing data gracefully' do
        expect { described_class.run(weather_data: weather_data) }.not_to raise_error
      end
    end

    context 'with multiple weather icons for same day' do
      let(:weather_data) do
        [
          {
            'dt' => timestamp1,
            'main' => { 'temp_max' => 25.6, 'temp_min' => 20.3, 'humidity' => 65 },
            'wind' => { 'speed' => 5.2 },
            'weather' => [{ 'icon' => '01d' }]
          },
          {
            'dt' => timestamp2,
            'main' => { 'temp_max' => 27.8, 'temp_min' => 19.5, 'humidity' => 70 },
            'wind' => { 'speed' => 6.1 },
            'weather' => [{ 'icon' => '02d' }]
          },
          {
            'dt' => timestamp2,
            'main' => { 'temp_max' => 26.5, 'temp_min' => 21.0, 'humidity' => 68 },
            'wind' => { 'speed' => 5.5 },
            'weather' => [{ 'icon' => '02d' }]
          }
        ]
      end

      it 'selects most common weather icon' do
        result = described_class.run(weather_data: weather_data).result
        expect(result.first[:most_common_icon]).to eq('02d')
      end
    end

    context 'with decimal values' do
      let(:weather_data) do
        [
          {
            'dt' => timestamp1,
            'main' => {
              'temp_max' => 25.6,
              'temp_min' => 20.3,
              'humidity' => 65.7
            },
            'wind' => {
              'speed' => 5.2
            },
            'weather' => [{ 'icon' => '01d' }]
          }
        ]
      end

      it 'rounds numerical values' do
        result = described_class.run(weather_data: weather_data).result
        expect(result.first[:max_temp]).to eq(26)
        expect(result.first[:min_temp]).to eq(20)
        expect(result.first[:humidity]).to eq(66)
        expect(result.first[:wind_speed]).to eq(5)
      end
    end
  end
end

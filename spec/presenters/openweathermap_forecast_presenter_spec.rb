# frozen_string_literal: true

require 'rails_helper'

describe OpenweathermapForecastPresenter do
  let(:longitude) { -79.718903 }
  let(:latitude) { 43.570816 }

  describe '#extract_forecast_data' do
    subject { described_class.extract_forecast_data(forecast_data) }

    let(:forecast_data) do
      VCR.use_cassette('openweathermap_client_forecast_200') do
        OpenweathermapClient.run(lon: longitude, lat: latitude, current_weather: false).result['list']
      end
    end

    it 'returns consolidated data' do
      expect(subject).to eq(expected_grouped_data_by_date)
    end

    def expected_grouped_data_by_date
      [
        {
          date: '2024-11-28',
          most_common_icon: '04d',
          icon_alt: 'Broken clouds (daytime)',
          humidity: 62,
          wind_speed: 4,
          max_temp: 5,
          min_temp: 1
        },
        {
          date: '2024-11-29',
          most_common_icon: '04n',
          icon_alt: 'Broken clouds (nighttime)',
          humidity: 61,
          wind_speed: 6,
          max_temp: 2,
          min_temp: -1
        },
        {
          date: '2024-11-30',
          most_common_icon: '04n',
          icon_alt: 'Broken clouds (nighttime)',
          humidity: 65,
          wind_speed: 7,
          max_temp: 0,
          min_temp: -2
        },
        {
          date: '2024-12-01',
          most_common_icon: '04n',
          icon_alt: 'Broken clouds (nighttime)',
          humidity: 79,
          wind_speed: 5,
          max_temp: 1,
          min_temp: -3
        },
        {
          date: '2024-12-02',
          most_common_icon: '04n',
          icon_alt: 'Broken clouds (nighttime)',
          humidity: 82,
          wind_speed: 3,
          max_temp: 1,
          min_temp: -3
        },
        {
          date: '2024-12-03',
          most_common_icon: '04n',
          icon_alt: 'Broken clouds (nighttime)',
          humidity: 79,
          wind_speed: 2,
          max_temp: 0,
          min_temp: -4
        }
      ]
    end
  end
end

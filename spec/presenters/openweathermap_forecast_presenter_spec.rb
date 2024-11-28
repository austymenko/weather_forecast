# frozen_string_literal: true

require 'rails_helper'

describe OpenweathermapForecastPresenter do
  it 'returns consolidated data' do
    outcome = nil
    VCR.use_cassette('openweathermap_client_forecast_200') do
      outcome = OpenweathermapClient.run(
        lon: -79.718903,
        lat: 43.570816,
        current_weather: false
      )
    end
    response_hash = outcome.result
    data = OpenweathermapForecastPresenter.group_forecast_data_by_date(
      response_hash['list']
    )

    expect(data).to eq(expected_grouped_data_by_date)
  end

  def expected_grouped_data_by_date
    [{ date: '2024-11-28', most_common_icon: '04d', humidity: 62, wind_speed: 4, max_temp: 5, min_temp: 1 },
     { date: '2024-11-29', most_common_icon: '04n', humidity: 61, wind_speed: 6, max_temp: 2,
       min_temp: -1 },
     { date: '2024-11-30', most_common_icon: '04n', humidity: 65, wind_speed: 7, max_temp: 0,
       min_temp: -2 },
     { date: '2024-12-01', most_common_icon: '04n', humidity: 79, wind_speed: 5, max_temp: 1,
       min_temp: -3 },
     { date: '2024-12-02', most_common_icon: '04n', humidity: 82, wind_speed: 3, max_temp: 1,
       min_temp: -3 },
     { date: '2024-12-03', most_common_icon: '04n', humidity: 79, wind_speed: 2, max_temp: 0,
       min_temp: -4 }]
  end
end

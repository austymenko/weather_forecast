# frozen_string_literal: true

require 'faraday'
require 'faraday/retry'

class OpenweathermapClient < BaseHttpClient
  string :api_key, default: ENV['OPENWEATHERMAP_APP_ID']
  float :lat
  float :lon
  boolean :current_weather, default: true

  with_error_processing

  def execute
    if current_weather
      fetch_current_weather
    else
      fetch_forecast
    end
  end

  private

  def url
    'https://api.openweathermap.org/'
  end

  def weather_path
    '/data/2.5/weather'
  end

  def forecast_path
    '/data/2.5/forecast'
  end

  def get_forecast
    faraday.get(forecast_path, {
                  lat: lat,
                  lon: lon,
                  appid: api_key,
                  units: 'metric'
                })
  end

  def get_current_weather
    faraday.get(weather_path, {
                  lat: lat,
                  lon: lon,
                  appid: api_key,
                  units: 'metric'
                })
  end

  def fetch_current_weather
    get_current_weather.body
  end

  def fetch_forecast
    get_forecast.body
  end
end

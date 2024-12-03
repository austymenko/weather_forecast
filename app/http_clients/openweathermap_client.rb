# frozen_string_literal: true

require 'faraday'
require 'faraday/retry'

# The OpenweathermapClient class is responsible for making HTTP requests to the OpenWeatherMap API
# to fetch current weather data and weather forecasts.
class OpenweathermapClient < BaseHttpClient
  # @param api_key [String] The API key for the OpenWeatherMap API. Defaults to the value of the `OPENWEATHERMAP_APP_ID` environment variable.
  # @param lat [Float] The latitude of the location to fetch weather data for.
  # @param lon [Float] The longitude of the location to fetch weather data for.
  # @param current_weather [Boolean] Whether to fetch current weather data or weather forecast data. Default is true.
  string :api_key, default: ENV['OPENWEATHERMAP_APP_ID']
  float :lat
  float :lon
  boolean :current_weather, default: true

  with_error_processing

  # Executes the HTTP request to the OpenWeatherMap API to fetch the current weather data or weather forecast.
  # @return [Hash] The parsed JSON response from the OpenWeatherMap API.
  def execute
    if current_weather
      fetch_current_weather
    else
      fetch_forecast
    end
  end

  private

  # Returns the base URL for the OpenWeatherMap API.
  # @return [String] The base URL for the OpenWeatherMap API.
  def url
    'https://api.openweathermap.org/'
  end

  # Returns the path for the current weather endpoint on the OpenWeatherMap API.
  # @return [String] The path for the current weather endpoint.
  def weather_path
    '/data/2.5/weather'
  end

  # Returns the path for the weather forecast endpoint on the OpenWeatherMap API.
  # @return [String] The path for the weather forecast endpoint.
  def forecast_path
    '/data/2.5/forecast'
  end

  # Makes a GET request to the OpenWeatherMap weather forecast endpoint with the provided parameters.
  # @return [Faraday::Response] The HTTP response from the weather forecast endpoint.
  def get_forecast
    faraday.get(forecast_path, {
                  lat: lat,
                  lon: lon,
                  appid: api_key,
                  units: 'metric'
                })
  end

  # Makes a GET request to the OpenWeatherMap current weather endpoint with the provided parameters.
  # @return [Faraday::Response] The HTTP response from the current weather endpoint.
  def get_current_weather
    faraday.get(weather_path, {
                  lat: lat,
                  lon: lon,
                  appid: api_key,
                  units: 'metric'
                })
  end

  # Fetches the current weather data from the OpenWeatherMap API and returns the parsed JSON response.
  # @return [Hash] The parsed JSON response from the current weather endpoint.
  def fetch_current_weather
    get_current_weather.body
  end

  # Fetches the weather forecast data from the OpenWeatherMap API and returns the parsed JSON response.
  # @return [Hash] The parsed JSON response from the weather forecast endpoint.
  def fetch_forecast
    get_forecast.body
  end
end

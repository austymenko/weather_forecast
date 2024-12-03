# frozen_string_literal: true

module WeatherProviders
  # The OpenweathermapProvider class is a concrete implementation of the WeatherProviders::Base
  # interface. It is responsible for fetching weather data from the OpenWeatherMap API.
  class OpenweathermapProvider < Base
    # Fetches weather data from the OpenWeatherMap API based on the provided latitude, longitude, and
    # whether the data should be for the current weather or forecast.
    # @param lat [Float] The latitude of the location to fetch weather data for.
    # @param lon [Float] The longitude of the location to fetch weather data for.
    # @param current_weather [Boolean] Whether to fetch current weather data or forecast data.
    # @return [Hash, Array<Hash>] The raw response from the OpenWeatherMap API, containing the weather data.
    def fetch_weather(lat:, lon:, current_weather:)
      OpenweathermapService.run(
        lat: lat,
        lon: lon,
        current_weather: current_weather
      )
    end
  end
end
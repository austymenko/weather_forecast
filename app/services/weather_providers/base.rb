# frozen_string_literal: true

module WeatherProviders
  # The WeatherProviders::Base class defines the strategy interface for weather providers.
  # Concrete weather provider implementations should inherit from this class and implement
  # the necessary methods.
  class Base
    # Fetches weather data based on the provided latitude, longitude, and whether the
    # data should be for the current weather or forecast.
    # @param lat [Float] The latitude of the location to fetch weather data for.
    # @param lon [Float] The longitude of the location to fetch weather data for.
    # @param current_weather [Boolean] Whether to fetch current weather data or forecast data.
    # @return [Hash, Array<Hash>] The raw response from the weather provider, containing the weather data.
    def fetch_weather(lat:, lon:, current_weather:)
      raise NotImplementedError, "#{self.class} must implement #fetch_weather"
    end
  end
end
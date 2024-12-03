# frozen_string_literal: true

# The WeatherService class is responsible for fetching weather data from a weather provider,
# caching the data in Redis, and returning the data along with the cache age.
class WeatherService < ActiveInteraction::Base
  # @param current_weather [Boolean] Whether to fetch current weather data or forecast data. Default is true.
  # @param country [String] The country of the location to fetch weather data for.
  # @param postcode [String] The postal code of the location to fetch weather data for.
  # @param lat [Float] The latitude of the location to fetch weather data for.
  # @param lon [Float] The longitude of the location to fetch weather data for.
  # @param redis_weather_key_ttl [Integer] The time-to-live (TTL) for the cached weather data in seconds. Default is 1800 (30 minutes).
  boolean :current_weather, default: true
  string :country
  string :postcode
  float :lat
  float :lon
  integer :redis_weather_key_ttl, default: 1800

  # Can be configured in application.rb or through environment variables
  DEFAULT_WEATHER_PROVIDER = :openweathermap

  # Executes the weather data fetching and caching logic.
  # @return [Hash] A hash containing the weather data and the cache age.
  # The weather data is either a Hash (for current weather) or an Array of Hashes (for forecast data).
  # The cache age is an Integer representing the number of seconds since the data was cached.
  def execute
    redis_key = redis_key_for(country, postcode)

    weather_data = RedisCacheService.fetch(redis_key, ttl: redis_weather_key_ttl) do
      fetch_weather
    end

    cache_age = RedisCacheService.age(redis_key, redis_weather_key_ttl)

    weather_data = if weather_data.is_a?(Hash)
                     weather_data.symbolize_keys
                   else
                     weather_data.map { |hash| hash.transform_keys(&:to_sym) }
                   end

    { weather_data: weather_data, cache_age: cache_age }
  rescue StandardError => e
    errors.add(:weather_service_error, e.message)
  end

  private

  # Fetches the weather data from the configured weather provider.
  # @return [Hash, Array<Hash>] The weather data, either a Hash (for current weather) or an Array of Hashes (for forecast data).
  def fetch_weather
    outcome = weather_provider.fetch_weather(
      lat:,
      lon:,
      current_weather: current_weather
    )

    outcome.result
  end

  # Generates a Redis key for the cached weather data based on the country and postal code.
  # @param country [String] The country of the location.
  # @param postal_code [String] The postal code of the location.
  # @return [String] The Redis key for the cached weather data.
  def redis_key_for(country, postal_code)
    # remove extra spaces, convert to lowercase, replace spaces with dashes
    formatted_country = country.strip.downcase.gsub(/\s+/, '-')
    formatted_postal = postal_code.strip.downcase.gsub(/\s+/, '-')

    key_prefix = current_weather ? 'current_weather' : 'forecast'

    "#{key_prefix}:#{formatted_country}:#{formatted_postal}"
  end

  # Retrieves the configured weather provider.
  # @return [WeatherProviders::Base] The weather provider instance.
  def weather_provider
    @weather_provider ||= WeatherProviders::Factory.for(provider_name)
  end

  # Determines the weather provider name.
  # @return [Symbol] The weather provider name.
  def provider_name
    DEFAULT_WEATHER_PROVIDER
    # params[:provider]&.to_sym || DEFAULT_WEATHER_PROVIDER
  end
end

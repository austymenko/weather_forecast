# frozen_string_literal: true

module Controllers
  # The WeatherStreamable module provides common functionality for controllers
  # that need to handle weather-related Turbo streams.
  module WeatherStreamable
    extend ActiveSupport::Concern

    private

    # Generates the Turbo streams for successful weather data responses.
    # @param weather_data [Hash, Array<Hash>] The weather data to be rendered.
    # @param cache_age [Integer, nil] The age of the cached weather data, or nil if the data was not cached.
    # @return [Array<Turbo::StreamTag>] An array of Turbo stream tags to be rendered.
    def success_streams(weather_data, cache_age)
      [
        weather_stream(weather_data, cache_age),
        clear_error_stream
      ]
    end

    # Generates the Turbo streams for error responses related to weather data.
    # @param outcome [ActiveInteraction::Base] The outcome object containing the errors.
    # @return [Array<Turbo::StreamTag>] An array of Turbo stream tags to be rendered.
    def error_streams(outcome)
      [
        error_stream(outcome),
        clear_suggestions_stream
      ]
    end

    # Generates a Turbo stream tag to replace the current weather or forecast container
    # with the provided weather data and cache age.
    # @param weather_data [Hash, Array<Hash>] The weather data to be rendered.
    # @param cache_age [Integer, nil] The age of the cached weather data, or nil if the data was not cached.
    # @return [Turbo::StreamTag] The Turbo stream tag for the weather data.
    def weather_stream(weather_data, cache_age)
      if weather_data.is_a?(Hash)
        turbo_stream.replace(
          'current-weather',
          partial: 'api/v1/forecasts/current_weather',
          locals: { current_weather_data: weather_data, cache_age: cache_age }
        )
      else
        turbo_stream.replace(
          'forecast',
          partial: 'api/v1/forecasts/forecast',
          locals: { forecast_data: weather_data, cache_age: cache_age }
        )
      end
    end

    # Generates a Turbo stream tag to clear the address errors container.
    # @return [Turbo::StreamTag] The Turbo stream tag for clearing the address errors.
    def clear_error_stream
      turbo_stream.replace(
        'address-errors',
        partial: 'shared/errors',
        locals: { errors: [] }
      )
    end

    # Generates a Turbo stream tag to replace the address errors container with the
    # provided error messages.
    # @param outcome [ActiveInteraction::Base] The outcome object containing the error messages.
    # @return [Turbo::StreamTag] The Turbo stream tag for the address errors.
    def error_stream(outcome)
      turbo_stream.replace(
        'address-errors',
        partial: 'shared/errors',
        locals: { errors: outcome.errors.full_messages }
      )
    end

    # Generates a Turbo stream tag to clear the address suggestions container.
    # @return [Turbo::StreamTag] The Turbo stream tag for clearing the address suggestions.
    def clear_suggestions_stream
      turbo_stream.replace(
        'address-suggestions',
        partial: 'suggestions/suggestions',
        locals: { suggestions: [] }
      )
    end
  end
end

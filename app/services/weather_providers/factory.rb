# frozen_string_literal: true

module WeatherProviders
  # The WeatherProviders::Factory class is responsible for creating instances of
  # concrete weather provider implementations based on the specified provider name.
  class Factory
    # A hash that maps provider names to their corresponding provider classes.
    PROVIDERS = {
      openweathermap: OpenweathermapProvider
    }.freeze

    # Creates an instance of the weather provider specified by the given provider name.
    # @param provider_name [Symbol] The name of the weather provider to create.
    # @return [WeatherProviders::Base] An instance of the specified weather provider.
    # @raise [ArgumentError] If the specified provider name is unknown.
    def self.for(provider_name)
      PROVIDERS.fetch(provider_name).new
    rescue KeyError
      raise ArgumentError, "Unknown weather provider: #{provider_name}"
    end
  end
end
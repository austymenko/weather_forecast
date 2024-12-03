# frozen_string_literal: true

module AddressProviders
  # The AddressProviders::Factory class is responsible for creating instances of
  # concrete address provider implementations based on the specified provider name.
  class Factory
    # A hash that maps provider names to their corresponding provider classes.
    PROVIDERS = {
      mapbox: MapboxProvider
    }.freeze

    # Creates an instance of the address provider specified by the given provider name.
    # @param provider_name [Symbol] The name of the address provider to create.
    # @return [AddressProviders::Base] An instance of the specified address provider.
    # @raise [ArgumentError] If the specified provider name is unknown.
    def self.for(provider_name)
      PROVIDERS.fetch(provider_name).new
    rescue KeyError
      raise ArgumentError, "Unknown provider: #{provider_name}"
    end
  end
end
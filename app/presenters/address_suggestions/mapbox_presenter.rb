# frozen_string_literal: true

module AddressSuggestions
  # The AddressSuggestions::MapboxPresenter class is a concrete implementation of the
  # AddressSuggestions::BasePresenter interface. It is responsible for formatting
  # address suggestions obtained from the Mapbox API.
  class MapboxPresenter < BasePresenter
    # Formats the raw address suggestion data from the Mapbox API into a standardized format.
    # @param data [Hash] The raw address suggestion data from the Mapbox API.
    # @return [Array<Hash>] An array of hashes containing the formatted address suggestions.
    def format_suggestions(data)
      ::MapboxPresenter.addresses_and_coordinates(data)
    end
  end
end

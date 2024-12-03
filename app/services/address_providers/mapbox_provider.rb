# frozen_string_literal: true

module AddressProviders
  # The MapboxProvider class is a concrete implementation of the AddressProviders::Base
  # interface. It is responsible for fetching address suggestions from the Mapbox API.
  class MapboxProvider < Base
    # Fetches address suggestions from the Mapbox API based on the provided query.
    # @param query [String] The search query for address suggestions.
    # @return [Hash, Array<Hash>] The raw response from the Mapbox API, containing the address suggestions.
    def fetch_suggestions(query)
      MapboxClient.run(query: query)
    end
  end
end
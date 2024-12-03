# frozen_string_literal: true

# Let's define a strategy interface for address providers
module AddressProviders
  # The AddressProviders::Base class defines the strategy interface for address providers.
  # Concrete address provider implementations should inherit from this class and implement
  # the necessary methods.
  class Base
    # Fetches address suggestions based on the provided query.
    # @param query [String] The search query for address suggestions.
    # @return [Hash, Array<Hash>] The raw response from the address provider, containing the address suggestions.
    def fetch_suggestions(query)
      raise NotImplementedError, "#{self.class} must implement #fetch_suggestions"
    end
  end
end
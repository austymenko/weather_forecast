# frozen_string_literal: true

module AddressSuggestions
  # The AddressSuggestions::BasePresenter class defines the base interface for
  # address suggestion presenters. Concrete presenter implementations should
  # inherit from this class and implement the necessary methods.
  class BasePresenter
    # Formats the raw address suggestion data into a standardized format.
    # @param data [Array<Hash>] The raw address suggestion data.
    # @return [Array<Hash>] The formatted address suggestions.
    def format_suggestions(data)
      raise NotImplementedError, "#{self.class} must implement #format_suggestions"
    end
  end
end

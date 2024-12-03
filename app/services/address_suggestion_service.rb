# frozen_string_literal: true

# The AddressSuggestionService class is responsible for fetching and processing address suggestions
# from a configured address provider, such as Mapbox or Google Maps.
class AddressSuggestionService < BaseService
  with_error_processing

  # @param address_suggestions_params [ActionController::Parameters] The parameters containing the search query for address suggestions.
  # @param provider [Symbol] The address provider to use for fetching suggestions. Default is :mapbox.
  object :address_suggestions_params, class: ActionController::Parameters
  symbol :provider, default: :mapbox

  # Executes the address suggestion fetching and processing logic.
  # @return [Array<Hash>] An array of formatted address suggestion hashes.
  # If there are any errors, it returns an empty array and the errors are added to the `errors` attribute.
  def execute
    return [] if query.blank?

    fetch_and_process_locations
  end

  private

  # Fetches the location suggestions from the configured address provider and processes them.
  # @return [Array<Hash>, nil] The processed address suggestions, or nil if there are any errors.
  def fetch_and_process_locations
    locations = fetch_locations
    return if errors.any?

    process_locations(locations)
  end

  # Fetches the location suggestions from the configured address provider.
  # @return [Array<Hash>, nil] The raw location suggestions, or nil if there are any errors.
  def fetch_locations
    outcome = address_provider.fetch_suggestions(query)
    merge_errors_and_return(outcome)
  end

  # Processes the raw location suggestions using the appropriate suggestions presenter.
  # @param locations [Array<Hash>] The raw location suggestions.
  # @return [Array<Hash>] The formatted address suggestions.
  def process_locations(locations)
    suggestions_presenter.format_suggestions(locations)
  end

  # Merges any errors from the provided outcome and returns the result.
  # @param outcome [ActiveInteraction::Base] The outcome from a service or presenter.
  # @return [Object, nil] The result from the outcome, or nil if there are any errors.
  def merge_errors_and_return(outcome)
    if outcome.valid?
      outcome.result
    else
      errors.merge!(outcome.errors)
      nil
    end
  end

  # Retrieves the search query from the address suggestions parameters.
  # @return [String] The search query.
  def query
    address_suggestions_params['query']
  end

  # Retrieves the configured address provider instance.
  # @return [AddressProviders::Base] The address provider instance.
  def address_provider
    @address_provider ||= AddressProviders::Factory.for(provider)
  end

  # Retrieves the configured suggestions presenter instance.
  # @return [AddressSuggestions::PresenterBase] The suggestions presenter instance.
  def suggestions_presenter
    @suggestions_presenter ||= "AddressSuggestions::#{provider.to_s.camelize}Presenter".constantize.new
  end
end

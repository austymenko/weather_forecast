# frozen_string_literal: true

class AddressSuggestionService < BaseService
  with_error_processing

  object :address_suggestions_params, class: ActionController::Parameters

  def execute
    return [] if query.blank?

    geocoding_result = MapboxClient.run(query: query)
    mapbox_locations = geocoding_result.result

    MapboxPresenter.addresses_and_coordinates(mapbox_locations)
  end

  private

  def query
    address_suggestions_params['query']
  end
end

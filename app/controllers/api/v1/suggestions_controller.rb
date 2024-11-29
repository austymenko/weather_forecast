# frozen_string_literal: true

module Api
  module V1
    class SuggestionsController < ApplicationController
      def index
        suggestions = fetch_address_suggestions(suggestion_params)
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: turbo_stream.replace(
              'address-suggestions',
              partial: 'suggestions/suggestions',
              locals: { suggestions: suggestions }
            )
          end
        end
      end

      private

      def suggestion_params
        params.permit(:query)
      end

      def fetch_address_suggestions(suggestion_params)
        query = suggestion_params['query']
        return [] if query.blank?

        geocoding_result = MapboxClient.run(query: query)
        mapbox_locations = geocoding_result.result

        MapboxPresenter.addresses_and_coordinates(mapbox_locations)
      end
    end
  end
end

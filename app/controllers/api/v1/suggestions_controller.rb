# frozen_string_literal: true

module Api
  module V1
    # The SuggestionsController class is responsible for handling requests for address suggestions.
    class SuggestionsController < ApplicationController
      include Controllers::SuggestionsStreamable

      # Renders the Turbo streams for the address suggestions.
      def index
        render_suggestions(fetch_suggestions)
      end

      private

      # Fetches the address suggestions using the AddressSuggestionService.
      # @return [ActiveInteraction::Outcome] The outcome of the AddressSuggestionService execution.
      def fetch_suggestions
        AddressSuggestionService.run(
          address_suggestions_params: params,
          provider: :mapbox
        )
      end

      # Renders the Turbo streams for the address suggestions or errors.
      # @param outcome [ActiveInteraction::Outcome] The outcome of the AddressSuggestionService execution.
      def render_suggestions(outcome)
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: outcome.valid? ? success_streams(outcome) : error_streams(outcome)
          end
        end
      end

      # Retrieves the suggestion parameters from the request.
      # @return [ActionController::Parameters] The suggestion parameters.
      def suggestion_params
        params.permit(:query)
      end
    end
  end
end

# frozen_string_literal: true

module Api
  module V1
    class SuggestionsController < ApplicationController
      def index
        outcome = AddressSuggestionService.run(address_suggestions_params: suggestion_params)

        respond_to do |format|
          format.turbo_stream do
            if outcome.valid?
              render turbo_stream: [
                turbo_stream.replace(
                  'address-suggestions',
                  partial: 'suggestions/suggestions',
                  locals: { suggestions: outcome.result }
                ),
                turbo_stream.replace(
                  'address-errors',
                  partial: 'suggestions/errors',
                  locals: { errors: [] }
                )
              ]
            else
              render turbo_stream: [
                turbo_stream.replace(
                  'address-errors',
                  partial: 'suggestions/errors',
                  locals: { errors: outcome.errors.full_messages }
                ),
                turbo_stream.replace(
                  'address-suggestions',
                  partial: 'suggestions/suggestions',
                  locals: { suggestions: [] }
                )
              ]
            end
          end
        end
      end

      private

      def suggestion_params
        params.permit(:query)
      end
    end
  end
end
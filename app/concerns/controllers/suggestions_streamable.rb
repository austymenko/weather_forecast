# frozen_string_literal: true

module Controllers
  # The SuggestionsStreamable module provides common functionality for controllers
  # that need to handle address suggestion-related Turbo streams.
  module SuggestionsStreamable
    extend ActiveSupport::Concern

    private

    # Generates the Turbo streams for successful address suggestion responses.
    # @param outcome [ActiveInteraction::Base] The outcome object containing the address suggestions.
    # @return [Array<Turbo::StreamTag>] An array of Turbo stream tags to be rendered.
    def success_streams(outcome)
      [
        suggestions_stream(outcome.result),
        clear_error_stream
      ]
    end

    # Generates the Turbo streams for error responses related to address suggestions.
    # @param outcome [ActiveInteraction::Base] The outcome object containing the errors.
    # @return [Array<Turbo::StreamTag>] An array of Turbo stream tags to be rendered.
    def error_streams(outcome)
      [
        error_stream(outcome),
        clear_suggestions_stream
      ]
    end

    # Generates a Turbo stream tag to replace the address suggestions container with the
    # provided suggestions.
    # @param suggestions [Array<Hash>] The address suggestions to be rendered.
    # @return [Turbo::StreamTag] The Turbo stream tag for the address suggestions.
    def suggestions_stream(suggestions)
      turbo_stream.replace(
        'address-suggestions',
        partial: 'suggestions/suggestions',
        locals: { suggestions: suggestions }
      )
    end

    # Generates a Turbo stream tag to clear the address errors container.
    # @return [Turbo::StreamTag] The Turbo stream tag for clearing the address errors.
    def clear_error_stream
      turbo_stream.replace(
        'address-errors',
        partial: 'shared/errors',
        locals: { errors: [] }
      )
    end

    # Generates a Turbo stream tag to replace the address errors container with the
    # provided error messages.
    # @param outcome [ActiveInteraction::Base] The outcome object containing the error messages.
    # @return [Turbo::StreamTag] The Turbo stream tag for the address errors.
    def error_stream(outcome)
      turbo_stream.replace(
        'address-errors',
        partial: 'shared/errors',
        locals: { errors: outcome.errors.full_messages }
      )
    end

    # Generates a Turbo stream tag to clear the address suggestions container.
    # @return [Turbo::StreamTag] The Turbo stream tag for clearing the address suggestions.
    def clear_suggestions_stream
      turbo_stream.replace(
        'address-suggestions',
        partial: 'suggestions/suggestions',
        locals: { suggestions: [] }
      )
    end
  end
end

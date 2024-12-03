# frozen_string_literal: true

# The BaseService class is an abstract base class that provides common functionality for
# service objects in the application, such as error processing.
class BaseService < ActiveInteraction::Base
  # Adds an around callback to the `execute` method that handles any StandardError
  # exceptions and adds them to the `errors` attribute.
  def self.with_error_processing
    set_callback :execute, :around, lambda { |_interaction, block|
      begin
        block.call
      rescue StandardError => e
        errors.add(:service_error, e.message)
      end
    }
  end
end

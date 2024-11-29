# frozen_string_literal: true

class BaseService < ActiveInteraction::Base
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

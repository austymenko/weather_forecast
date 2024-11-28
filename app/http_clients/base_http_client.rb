# frozen_string_literal: true

class BaseHttpClient < ActiveInteraction::Base
  attr_accessor :response

  def self.with_error_processing
    set_callback :execute, :around, lambda { |_interaction, block|
      begin
        block.call
      rescue *Faraday::Response::RaiseError::ClientErrorStatusesWithCustomExceptions.values => e
        errors.add(:mapbox_client_error, e.message)
      rescue StandardError => _e
        errors.add(:mapbox_client_error, 'server error')
      end
    }
  end

  def faraday
    @faraday ||= Faraday.new(url: url) do |config|
      config.request :json
      config.response :json
      config.request :retry, {
        max: 5,                   # Retry a failed request up to 5 times
        interval: 0.5,            # First retry after 0.5s
        backoff_factor: 2,        # Double the delay for each subsequent retry
        interval_randomness: 0.5, # Specify "jitter" of up to 50% of interval
        retry_statuses: [429],    # Retry only when we get a 429 response
        methods: [:get]           # Retry only GET requests
      }
      config.response :raise_error
      config.adapter :net_http
      config.options.timeout = 5 # 5 seconds timeout for the request
    end
  end
end

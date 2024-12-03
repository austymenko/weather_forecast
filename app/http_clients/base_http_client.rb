# frozen_string_literal: true

# The BaseHttpClient class is an abstract base class that provides common functionality
# for HTTP client classes in the application, such as error processing and Faraday
# configuration.
class BaseHttpClient < ActiveInteraction::Base
  # Allows the response from the HTTP request to be accessed as an attribute.
  attr_accessor :response

  # Adds an around callback to the `execute` method that handles any Faraday client
  # errors and adds them to the `errors` attribute.
  def self.with_error_processing
    set_callback :execute, :around, lambda { |_interaction, block|
      begin
        block.call
      rescue *Faraday::Response::RaiseError::ClientErrorStatusesWithCustomExceptions.values => e
        errors.add(:mapbox_client_error, e.message)
      rescue StandardError => e
        errors.add(:mapbox_client_error, e.message)
      end
    }
  end

  # Configures and returns a Faraday HTTP client instance.
  # @return [Faraday::Connection] The configured Faraday HTTP client.
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

  # Returns the base URL for the HTTP client. Subclasses should override this method
  # to provide the appropriate base URL.
  # @return [String] The base URL for the HTTP client.
  def url
    raise NotImplementedError, "#{self.class} must implement #url"
  end
end

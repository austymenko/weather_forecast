# frozen_string_literal: true

require 'faraday'
require 'faraday/retry'

# The MapboxClient class is responsible for making HTTP requests to the Mapbox API
# to fetch address suggestions based on a user's search query.
class MapboxClient < BaseHttpClient
  # @param access_token [String] The access token for the Mapbox API. Defaults to the value of the `MAPBOX_ACCESS_TOKEN` environment variable.
  # @param query [String] The search query to use when fetching address suggestions.
  string :access_token, default: ENV['MAPBOX_ACCESS_TOKEN']
  string :query

  with_error_processing

  # Executes the HTTP request to the Mapbox API to fetch the address suggestions.
  # @return [Hash] The parsed JSON response from the Mapbox API.
  def execute
    return unless query.present?

    fetch_places
  end

  private

  # Returns the base URL for the Mapbox API.
  # @return [String] The base URL for the Mapbox API.
  def url
    'https://api.mapbox.com/'
  end

  # Returns the path for the forward geocoding endpoint on the Mapbox API.
  # @return [String] The path for the forward geocoding endpoint.
  def forward_path
    '/search/geocode/v6/forward'
  end

  # Makes a GET request to the Mapbox forward geocoding endpoint with the provided parameters.
  # @return [Faraday::Response] The HTTP response from the forward geocoding endpoint.
  def get
    faraday.get(forward_path, {
                  q: query,
                  types: 'address',
                  language: 'en',
                  access_token: access_token
                })
  end

  # Fetches the address suggestions from the Mapbox API and returns the parsed JSON response.
  # @return [Hash] The parsed JSON response from the forward geocoding endpoint.
  def fetch_places
    get.body
  end
end

# frozen_string_literal: true

# The MapboxPresenter class is responsible for processing the raw location data
# from the Mapbox API and formatting it into a standardized hash structure.
class MapboxPresenter < BasePresenter
  include CoordinateValidatable

  # @param places_data [Hash] The raw location data from the Mapbox API.
  hash :places_data, default: {}, strip: false

  with_error_processing

  # Extracts the address, coordinates, postal code, and country from the Mapbox location data.
  # @param places_data [Hash] The raw location data from the Mapbox API.
  # @return [Array<Hash>] An array of hashes containing the extracted location data.
  def self.addresses_and_coordinates(places_data)
    outcome = run(places_data: places_data)
    outcome.result if outcome.valid?
  end

  # Executes the location data processing logic and returns the formatted location suggestions.
  # @return [Array<Hash>] An array of hashes containing the formatted location suggestions.
  def execute
    extract_locations
  end

  private

  # Extracts the location data from the Mapbox API response.
  # @return [Array<Hash>] An array of hashes containing the extracted location data.
  def extract_locations
    features.filter_map do |location|
      extract_location_data(location) if valid_location?(location)
    end
  end

  # Retrieves the 'features' array from the Mapbox API response.
  # @return [Array<Hash>] The array of location feature hashes.
  def features
    places_data.fetch('features', [])
  end

  # Extracts the relevant location data from a single Mapbox location feature.
  # @param location [Hash] The Mapbox location feature hash.
  # @return [Hash] A hash containing the extracted location data.
  def extract_location_data(location)
    {
      address: location.dig('properties', 'full_address'),
      lat: location.dig('geometry', 'coordinates', 1),
      lon: location.dig('geometry', 'coordinates', 0),
      postcode: location.dig('properties', 'context', 'postcode', 'name'),
      country: location.dig('properties', 'context', 'country', 'name')
    }
  end

  # Checks if a Mapbox location feature is valid (has an address and valid coordinates).
  # @param location [Hash] The Mapbox location feature hash.
  # @return [Boolean] True if the location is valid, false otherwise.
  def valid_location?(location)
    address = location.dig('properties', 'full_address')
    coordinates = location.dig('geometry', 'coordinates')

    address.present? && valid_coordinates?(coordinates)
  end

  # Checks if the provided coordinates are valid (latitude and longitude are within acceptable ranges).
  # @param coordinates [Array] The array of latitude and longitude coordinates.
  # @return [Boolean] True if the coordinates are valid, false otherwise.
  def valid_coordinates?(coordinates)
    return false unless coordinates.is_a?(Array) && coordinates.size >= 2

    valid_latitude?(coordinates[1]) && valid_longitude?(coordinates[0])
  end
end

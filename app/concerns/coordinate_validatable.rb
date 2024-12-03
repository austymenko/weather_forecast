# frozen_string_literal: true

# The CoordinateValidatable module provides functionality for validating latitude and longitude coordinates.
module CoordinateValidatable
  extend ActiveSupport::Concern

  # The valid range for latitude values.
  LATITUDE_RANGE = (-90..90)

  # The valid range for longitude values.
  LONGITUDE_RANGE = (-180..180)

  included do
    # Checks if the provided latitude value is valid (within the specified range and numeric).
    # @param lat [Numeric] The latitude value to be validated.
    # @return [Boolean] True if the latitude value is valid, false otherwise.
    def valid_latitude?(lat)
      lat.is_a?(Numeric) && LATITUDE_RANGE.include?(lat)
    end

    # Checks if the provided longitude value is valid (within the specified range and numeric).
    # @param lon [Numeric] The longitude value to be validated.
    # @return [Boolean] True if the longitude value is valid, false otherwise.
    def valid_longitude?(lon)
      lon.is_a?(Numeric) && LONGITUDE_RANGE.include?(lon)
    end
  end

  class_methods do
    # Adds latitude and longitude validation rules to the including class.
    # The rules ensure that the latitude and longitude values are present, numeric,
    # and within the valid ranges.
    def validates_coordinates
      validates :lat, :lon, numericality: { only_numeric: true }
      validates :lat, presence: true, numericality: {
        greater_than_or_equal_to: LATITUDE_RANGE.min,
        less_than_or_equal_to: LATITUDE_RANGE.max
      }
      validates :lon, presence: true, numericality: {
        greater_than_or_equal_to: LONGITUDE_RANGE.min,
        less_than_or_equal_to: LONGITUDE_RANGE.max
      }
    end
  end
end

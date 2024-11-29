# frozen_string_literal: true

class MapboxPresenter
  def self.addresses_and_coordinates(places_data)
    places_data['features'].map do |location|
      {
        address: location.dig('properties', 'full_address'),
        lat: location.dig('geometry', 'coordinates', 1),
        lon: location.dig('geometry', 'coordinates', 0)
      }
    end
  end
end

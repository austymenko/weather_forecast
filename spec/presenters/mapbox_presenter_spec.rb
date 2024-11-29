# frozen_string_literal: true

require 'rails_helper'

describe MapboxPresenter do
  let(:search_query) { '5524 credit' }
  let(:geocoding_result) do
    VCR.use_cassette('mapbox_client_200') do
      MapboxClient.run(query: search_query)
    end
  end
  let(:mapbox_locations) { geocoding_result.result }
  let(:expected_locations) do
    [
      {
        address: '5524 Creditrise Place, Mississauga, Ontario L5M 6E3, Canada',
        lat: 43.570816,
        lon: -79.718903
      },
      {
        address: '5524 Creditview Road, Mississauga, Ontario L5V 1R8, Canada',
        lat: 43.590398,
        lon: -79.702227
      },
      {
        address: '5524 Credit River Road Southeast, Prior Lake, Minnesota 55372, United States',
        lat: 44.705797,
        lon: -93.407343
      }
    ]
  end

  describe '.addresses_and_coordinates' do
    subject(:locations_with_coordinates) { MapboxPresenter.addresses_and_coordinates(mapbox_locations) }

    it 'returns formatted locations with coordinates' do
      expect(locations_with_coordinates).to eq(expected_locations)
    end
  end
end

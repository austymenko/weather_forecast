# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MapboxPresenter do
  describe '.addresses_and_coordinates' do
    let(:places_data) do
      {
        'features' => [
          {
            'properties' => {
              'full_address' => '5524 Creditrise Place, Mississauga, Ontario L5M 6E3, Canada',
              'context' => {
                'postcode' => { 'name' => 'L5M 6E3' },
                'country' => { 'name' => 'Canada' }
              }
            },
            'geometry' => {
              'coordinates' => [-79.718903, 43.570816]
            }
          },
          {
            'properties' => {
              'full_address' => '5524 Creditview Road, Mississauga, Ontario L5V 1R8, Canada',
              'context' => {
                'postcode' => { 'name' => 'L5V 1R8' },
                'country' => { 'name' => 'Canada' }
              }
            },
            'geometry' => {
              'coordinates' => [-79.702227, 43.590398]
            }
          },
          {
            'properties' => {
              'full_address' => '5524 Credit River Road Southeast, Prior Lake, Minnesota 55372, United States',
              'context' => {
                'postcode' => { 'name' => '55372' },
                'country' => { 'name' => 'United States' }
              }
            },
            'geometry' => {
              'coordinates' => [-93.407343, 44.705797]
            }
          }
        ]
      }
    end

    it 'returns formatted locations with coordinates' do
      expect(described_class.addresses_and_coordinates(places_data)).to eq([
                                                                             {
                                                                               address: '5524 Creditrise Place, Mississauga, Ontario L5M 6E3, Canada',
                                                                               postcode: 'L5M 6E3',
                                                                               country: 'Canada',
                                                                               lat: 43.570816,
                                                                               lon: -79.718903
                                                                             },
                                                                             {
                                                                               address: '5524 Creditview Road, Mississauga, Ontario L5V 1R8, Canada',
                                                                               postcode: 'L5V 1R8',
                                                                               country: 'Canada',
                                                                               lat: 43.590398,
                                                                               lon: -79.702227
                                                                             },
                                                                             {
                                                                               address: '5524 Credit River Road Southeast, Prior Lake, Minnesota 55372, United States',
                                                                               postcode: '55372',
                                                                               country: 'United States',
                                                                               lat: 44.705797,
                                                                               lon: -93.407343
                                                                             }
                                                                           ])
    end
  end
end

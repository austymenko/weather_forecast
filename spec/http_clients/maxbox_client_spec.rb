# frozen_string_literal: true

require 'rails_helper'

describe MapboxClient do
  let(:query) { '5524 credit' }

  describe '.run' do
    context 'when authentication fails' do
      let(:wrong_token) { 'wrong token' }

      before do
        allow_any_instance_of(described_class)
          .to receive(:access_token).and_return(wrong_token)
      end

      let(:unauthorized_result) do
        VCR.use_cassette('mapbox_client_401') do
          MapboxClient.run(query: '5524 creditrise')
        end
      end

      it 'returns unauthorized error' do
        expect(unauthorized_result.valid?).to be_falsy
        expect(unauthorized_result.errors.messages)
          .to eq(
            { mapbox_client_error: ['the server responded with status 401'] }
          )
      end
    end

    context 'when request is successful' do
      let(:geocoding_result) do
        VCR.use_cassette('mapbox_client_200') do
          MapboxClient.run(query: query)
        end
      end

      let(:mapbox_response) { geocoding_result.result }
      let(:main_feature) { mapbox_response['features'].first }
      let(:full_addresses) do
        mapbox_response['features'].map { |feature| feature.dig('properties', 'full_address') }
      end

      let(:expected_addresses) do
        [
          '5524 Creditrise Place, Mississauga, Ontario L5M 6E3, Canada',
          '5524 Creditview Road, Mississauga, Ontario L5V 1R8, Canada',
          '5524 Credit River Road Southeast, Prior Lake, Minnesota 55372, United States'
        ]
      end

      let(:expected_geometry) do
        { 'type' => 'Point', 'coordinates' => [-79.718903, 43.570816] }
      end

      it 'returns successful response with location data' do
        expect(geocoding_result.valid?).to be_truthy
        expect(mapbox_response).to be_a(Hash)
        expect(mapbox_response).to include('features')
        expect(mapbox_response['features'].size).to eq(3)
        expect(main_feature['geometry']).to eq(expected_geometry)
        expect(full_addresses).to eq(expected_addresses)
      end
    end
  end
end

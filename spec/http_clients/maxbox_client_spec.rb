# frozen_string_literal: true

require 'rails_helper'

describe MapboxClient do
  it 'has 401 UnauthorizedError in response' do
    allow_any_instance_of(described_class)
      .to receive(:access_token).and_return('wrong token')

    outcome = nil

    VCR.use_cassette('mapbox_client_401') do
      query = '5524 creditrise'

      outcome = MapboxClient.run(query: query)
    end

    expect(outcome.valid?).to be_falsy
    expect(outcome.errors.messages)
      .to eq(
        { mapbox_client_error: ['the server responded with status 401'] }
      )
  end

  it 'has full_addresses in response' do
    outcome = nil

    VCR.use_cassette('mapbox_client_200') do
      outcome = MapboxClient.run(query: '5524 credit')
    end

    response_hash = outcome.result
    main_feature = response_hash['features'].first
    full_addresses = response_hash['features'].map do |feature|
      feature.dig('properties', 'full_address')
    end

    expect(outcome.valid?).to be_truthy
    expect(response_hash.class).to eq(Hash)
    expect(response_hash.keys.include?('features')).to be_truthy
    expect(response_hash['features'].size).to eq(3)
    expect(main_feature['geometry'])
      .to eq(
        { 'type' => 'Point', 'coordinates' => [-79.718903, 43.570816] }
      )
    expect(full_addresses)
      .to eq(
        [
          '5524 Creditrise Place, Mississauga, Ontario L5M 6E3, Canada',
          '5524 Creditview Road, Mississauga, Ontario L5V 1R8, Canada',
          '5524 Credit River Road Southeast, Prior Lake, Minnesota 55372, United States'
        ]
      )
  end
end

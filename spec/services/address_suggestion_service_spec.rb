# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AddressSuggestionService do
  let(:example_address) { '123 Dundas St E, Mississauga, ON L5A 1V2, Canada' }
  let(:params) { ActionController::Parameters.new(query: example_address) }

  describe '#execute' do
    subject { described_class.run(address_suggestions_params: params) }

    context 'when query is blank' do
      let(:example_address) { '' }

      it 'returns empty array' do
        expect(subject.result).to eq([])
      end
    end

    context 'when query is present' do
      let(:mapbox_result) { double('MapboxResult', result: mapbox_locations) }
      let(:mapbox_locations) do
        [
          {
            'place_name' => example_address,
            'center' => [longitude, latitude]
          }
        ]
      end
      let(:longitude) { -79.6441 }
      let(:latitude) { 43.5890 }
      let(:formatted_results) do
        [
          {
            address: example_address,
            lon: longitude,
            lat: latitude
          }
        ]
      end

      before do
        allow(MapboxClient).to receive(:run)
          .with(query: example_address)
          .and_return(mapbox_result)

        allow(MapboxPresenter).to receive(:addresses_and_coordinates)
          .with(mapbox_locations)
          .and_return(formatted_results)
      end

      it 'calls MapboxClient with query' do
        expect(MapboxClient).to receive(:run).with(query: example_address)
        subject
      end

      it 'formats results using MapboxPresenter' do
        expect(MapboxPresenter).to receive(:addresses_and_coordinates).with(mapbox_locations)
        subject
      end

      it 'returns formatted locations' do
        expect(subject.result).to eq(formatted_results)
      end
    end

    context 'when MapboxClient raises an error' do
      let(:example_address) { '123 Dundas St E, Mississauga, ON L5A 1V2, Canada' }

      before do
        allow(MapboxClient).to receive(:run)
          .and_raise(StandardError.new('API Error'))
      end

      it 'handles the error through with_error_processing' do
        outcome = subject
        expect(outcome).not_to be_valid
        expect(outcome.errors).to be_present
      end
    end
  end
end

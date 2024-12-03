# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AddressSuggestionService do
  let(:query) { 'New York' }
  let(:provider) { :mapbox }
  let(:address_suggestions_params) { ActionController::Parameters.new({ 'query' => query }) }
  let(:base_params) do
    {
      address_suggestions_params: address_suggestions_params,
      provider: provider
    }
  end

  let(:mock_provider) { instance_double('AddressProviders::Base') }
  let(:mock_provider_outcome) { instance_double('ActiveInteraction::Outcome') }
  let(:mock_presenter) { instance_double('AddressSuggestions::MapboxPresenter') }

  let(:raw_locations) do
    [
      { 'place_name' => 'New York, NY, USA', 'coordinates' => [-74.006, 40.7128] },
      { 'place_name' => 'New York Mills, MN, USA', 'coordinates' => [-95.3763, 46.5188] }
    ]
  end

  let(:formatted_locations) do
    [
      { address: 'New York, NY, USA', coordinates: { lat: 40.7128, lon: -74.006 } },
      { address: 'New York Mills, MN, USA', coordinates: { lat: 46.5188, lon: -95.3763 } }
    ]
  end

  before do
    allow(AddressProviders::Factory).to receive(:for).with(provider).and_return(mock_provider)
    allow(AddressSuggestions::MapboxPresenter).to receive(:new).and_return(mock_presenter)
  end

  describe '#execute' do
    context 'when query is blank' do
      let(:query) { '' }

      it 'returns empty array' do
        result = described_class.run!(base_params)
        expect(result).to eq([])
      end

      it 'does not call the address provider' do
        expect(mock_provider).not_to receive(:fetch_suggestions)
        described_class.run!(base_params)
      end
    end

    context 'when query is present' do
      before do
        allow(mock_provider).to receive(:fetch_suggestions).and_return(mock_provider_outcome)
        allow(mock_provider_outcome).to receive(:valid?).and_return(true)
        allow(mock_provider_outcome).to receive(:result).and_return(raw_locations)
        allow(mock_presenter).to receive(:format_suggestions).and_return(formatted_locations)
      end

      it 'fetches and processes locations' do
        result = described_class.run!(base_params)
        expect(result).to eq(formatted_locations)
      end

      it 'calls provider with correct query' do
        expect(mock_provider).to receive(:fetch_suggestions).with(query)
        described_class.run!(base_params)
      end

      it 'formats suggestions using presenter' do
        expect(mock_presenter).to receive(:format_suggestions).with(raw_locations)
        described_class.run!(base_params)
      end
    end

    context 'when provider fails' do
      let(:error_message) { 'API error' }
      let(:provider_errors) do
        ActiveModel::Errors.new(AddressProviders::Base.new).tap do |errors|
          errors.add(:service_error, error_message)
        end
      end

      before do
        allow(mock_provider).to receive(:fetch_suggestions).and_return(mock_provider_outcome)
        allow(mock_provider_outcome).to receive(:valid?).and_return(false)
        allow(mock_provider_outcome).to receive(:errors).and_return(provider_errors)
      end

      it 'adds provider errors to service errors' do
        outcome = described_class.run(base_params)
        expect(outcome.errors.full_messages).to include("Service error #{error_message}")
      end

      it 'does not process locations' do
        expect(mock_presenter).not_to receive(:format_suggestions)
        described_class.run(base_params)
      end
    end

    context 'when presenter fails' do
      before do
        allow(mock_provider).to receive(:fetch_suggestions).and_return(mock_provider_outcome)
        allow(mock_provider_outcome).to receive(:valid?).and_return(true)
        allow(mock_provider_outcome).to receive(:result).and_return(raw_locations)
        allow(mock_presenter).to receive(:format_suggestions).and_raise(StandardError.new('Formatting error'))
      end

      it 'handles presenter errors' do
        outcome = described_class.run(base_params)
        expect(outcome).not_to be_valid
        expect(outcome.errors.full_messages).to include('Service error Formatting error')
      end
    end
  end
end
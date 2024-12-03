# frozen_string_literal: true

require 'rails_helper'

module AddressProviders
  RSpec.describe MapboxProvider do
    describe '#fetch_suggestions' do
      let(:query) { 'New York' }
      let(:client_outcome) { instance_double('ActiveInteraction::Outcome') }

      before do
        allow(MapboxClient).to receive(:run).and_return(client_outcome)
      end

      it 'calls MapboxClient with correct query' do
        expect(MapboxClient).to receive(:run).with(query: query)
        described_class.new.fetch_suggestions(query)
      end

      it 'returns the client outcome directly' do
        result = described_class.new.fetch_suggestions(query)
        expect(result).to eq(client_outcome)
      end

      context 'with different query types' do
        queries = {
          'simple string' => 'London',
          'string with spaces' => 'San Francisco',
          'string with special chars' => 'São Paulo',
          'string with numbers' => '123 Main St',
          'string with punctuation' => 'St. John\'s'
        }

        queries.each do |type, test_query|
          it "handles #{type}" do
            expect(MapboxClient).to receive(:run).with(query: test_query)
            described_class.new.fetch_suggestions(test_query)
          end
        end
      end
    end
  end
end

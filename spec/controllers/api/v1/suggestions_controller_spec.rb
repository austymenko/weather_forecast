# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::SuggestionsController, type: :controller do
  render_views

  let(:query) { 'New York' }
  let(:base_params) { { query: query } }

  let(:suggestion_data) do
    [
      {
        address: '123 Main St, New York, NY',
        lat: 40.7128,
        lon: -74.0060
      }
    ]
  end

  let(:service_outcome) do
    double('AddressSuggestionOutcome',
           valid?: true,
           result: suggestion_data
    )
  end

  let(:turbo_stream_response) do
    "<turbo-stream action='replace' target='suggestions'>mock content</turbo-stream>"
  end

  describe '#index' do
    before do
      allow(AddressSuggestionService).to receive(:run).and_return(service_outcome)
      allow(controller).to receive(:success_streams).and_return([turbo_stream_response])
      request.accept = 'text/vnd.turbo-stream.html'
    end

    it 'calls AddressSuggestionService with correct parameters' do
      expect(AddressSuggestionService).to receive(:run).with(
        address_suggestions_params: kind_of(ActionController::Parameters),
        provider: :mapbox
      )

      get :index, params: base_params, format: :turbo_stream
    end

    it 'renders turbo stream response' do
      get :index, params: base_params, format: :turbo_stream
      expect(response.media_type).to eq Mime[:turbo_stream]
    end

    it 'includes success streams in response for valid outcome' do
      expect(controller).to receive(:success_streams).with(service_outcome).and_return([turbo_stream_response])
      get :index, params: base_params, format: :turbo_stream
    end

    context 'when service fails' do
      let(:error_outcome) do
        double('AddressSuggestionOutcome',
               valid?: false,
               errors: ['API error']
        )
      end

      before do
        allow(AddressSuggestionService).to receive(:run).and_return(error_outcome)
        allow(controller).to receive(:error_streams).and_return([turbo_stream_response])
      end

      it 'handles errors gracefully' do
        get :index, params: base_params, format: :turbo_stream
        expect(response).to have_http_status(:success)
      end

      it 'renders error streams' do
        expect(controller).to receive(:error_streams).with(error_outcome).and_return([turbo_stream_response])
        get :index, params: base_params, format: :turbo_stream
      end
    end

    context 'with empty query' do
      let(:query) { '' }

      it 'handles empty query gracefully' do
        get :index, params: base_params, format: :turbo_stream
        expect(response).to have_http_status(:success)
      end
    end

    context 'with special characters in query' do
      let(:query) { 'New York & Co.' }

      it 'handles special characters gracefully' do
        get :index, params: base_params, format: :turbo_stream
        expect(response).to have_http_status(:success)
      end
    end

    context 'with unicode characters in query' do
      let(:query) { 'São Paulo' }

      it 'handles unicode characters gracefully' do
        get :index, params: base_params, format: :turbo_stream
        expect(response).to have_http_status(:success)
      end
    end
  end
end
require 'rails_helper'

RSpec.describe FetchSuggestedAddresses do
  let(:search_term) { %w[foo bar].sample }

  describe '.call' do
    context 'when MapboxApiService call succeeds' do
      it 'returns data' do
        expect_any_instance_of(MapboxApiService).to receive(:http_get)
          .with({ 'q' => search_term })
          .and_return(double(code: '200', body: {}))

        res = described_class.call(search_term)

        expect(res).to be_success
        expect(res.value!).to eq({})
      end
    end

    context 'when MapboxApiService call fails' do
      it 'returns a MapboxApiServiceError exception' do
        expect_any_instance_of(MapboxApiService).to receive(:http_get)
          .with({ 'q' => search_term.to_s })
          .and_return(double(code: '400'))

        res = described_class.call(search_term)

        expect(res).to be_failure
        expect(res.exception.class).to eq(Errors::MapboxApiServiceError)
        expect(res.exception.message).to eq('Error fetching address suggestions')
      end
    end
  end
end

require 'spec_helper'

describe CrystalSDK::Api do
  subject { CrystalSDK::Api }

  describe '.make_request' do
    context 'without api key' do
      it 'should raise an error' do
        expect { subject.make_request(:post, 'test') }
          .to raise_error(CrystalSDK::Base::ApiKeyNotSet)
      end
    end

    context 'with api key' do
      subject { CrystalSDK::Api.make_request(:post, 'test_endpoint') }

      let(:headers) do
        {
          'X-Org-Token' => 'SomeToken',
          'X-Sdk-Version' => CrystalSDK::VERSION
        }
      end

      let(:stubbed_req) do
        stub_request(:post, "#{CrystalSDK::Base::API_URL}/test_endpoint")
          .with(headers: headers)
      end

      before(:each) do
        allow(CrystalSDK::Base).to receive(:key).and_return('SomeToken')
      end

      context 'got 4xx response code' do
        it 'should raise an error' do
          stubbed_req
            .to_return(status: 404, body: '{}', headers: {})

          expect { subject }.to raise_error
        end
      end

      context 'got 5xx response code' do
        it 'should raise error on 5xx responses' do
          stubbed_req
            .to_return(status: 500, body: '{}', headers: {})

          expect { subject }.to raise_error
        end
      end

      context 'got 2xx response code' do
        it 'should return correct response' do
          stubbed_req
            .to_return(status: 200, body: 'stubbed', headers: {})

          expect(subject.code).to eql(200)
          expect(subject.body).to eql('stubbed')
        end
      end

      context 'given params' do
        subject do
          CrystalSDK::Api
            .make_request(:post, 'test_endpoint', params: params)
        end
        let(:params) { { some_param: '123'} }

        it 'should turn params into json body' do
          stubbed_req
            .with(body: params.to_json)
            .to_return(status: 200, body: 'stubbed', headers: {})

          expect { subject }.to_not raise_error
        end
      end


      context 'given headers' do
        subject do
          CrystalSDK::Api
            .make_request(:post, 'test_endpoint', headers: headers)
        end
        let(:headers) { { 'X-Some-Header' => '123' } }

        it 'should turn params into json body' do
          stubbed_req
            .with(headers: headers)
            .to_return(status: 200, body: 'stubbed', headers: {})

          expect { subject }.to_not raise_error
        end
      end
    end
  end
end

require 'spec_helper'

describe CrystalSDK::Profile do
  subject { CrystalSDK::Profile }

  describe '.search' do
    subject { CrystalSDK::Profile.search(query) }
    let(:query) { { some_param: 'a_param' } }
    let(:endpoint) { 'person_search' }
    let(:request_type) { :post }

    it 'should use the correct request' do
      expect(CrystalSDK::Profile).to receive(:make_request)
        .with(request_type, endpoint, params: query)
        .and_return(double(code: '200', body: {
          info: 'info',
          recommendations: 'recs'
        }.to_json))

      expect(subject.info).to eql('info')
      expect(subject.recommendations).to eql('recs')
    end

    context 'make_request raised unexpected error' do
      before(:each) do
        allow(CrystalSDK::Profile).to receive(:make_request)
          .with(request_type, endpoint, params: query)
          .and_raise("SomeRandomError")
      end

      it 'should not suppress the error' do
        expect { subject }.to raise_error('SomeRandomError')
      end
    end

    context 'make_request raised expected error' do
      before(:each) do
        allow(CrystalSDK::Profile).to receive(:make_request)
          .with(request_type, endpoint, params: query)
          .and_raise(Nestful::ResponseError.new(nil, double()))
      end

      it 'should pass it off to check_for_error' do
        expect(CrystalSDK::Profile).to receive(:check_for_error)
          .and_raise('CheckForErrorCalled')

        expect { subject }.to raise_error('CheckForErrorCalled')
      end

      it 'should still raise exception if passed check_for_error' do
        expect(CrystalSDK::Profile).to receive(:check_for_error)
          .and_return(nil)

        expect { subject }.to raise_error
      end
    end

    context 'make_request raised no error' do
      before(:each) do
        allow(CrystalSDK::Profile).to receive(:make_request)
          .with(request_type, endpoint, params: query)
          .and_return(response)
      end

      let(:response) do
        double(code: '200', body: { resp: 'some_resp' }.to_json)
      end

      it 'should still pass through check_for_error' do
        expect(CrystalSDK::Profile).to receive(:check_for_error)
          .with(response)
          .and_raise('CheckForErrorCalled')

        expect { subject }.to raise_error('CheckForErrorCalled')
      end
    end
  end

  describe '.check_for_error' do
    subject { CrystalSDK::Profile.check_for_error(resp) }

    context '200' do
      let(:resp) do
        body = { status: 'profile_found', info: nil, recommendations: nil }
        double(body: body.to_json, code: '200')
      end

      it 'should raise no error' do
        expect { subject }.to_not raise_error
      end
    end

    context '202' do
      let(:resp) { double(body: nil, code: '202') }

      it 'should raise NotFoundYetError' do
        expect { subject }.to raise_error(CrystalSDK::Profile::NotFoundYetError)
      end
    end

    context '401' do
      let(:resp) { double(body: nil, code: '401') }

      it 'should raise NotAuthedError' do
        expect { subject }.to raise_error(CrystalSDK::Profile::NotAuthedError)
      end
    end

    context '404' do
      let(:resp) { double(body: nil, code: '404') }

      it 'should raise NotFoundError' do
        expect { subject }.to raise_error(CrystalSDK::Profile::NotFoundError)
      end
    end

    context '429' do
      let(:resp) { double(body: nil, code: '429') }

      it 'should raise RateLimitHitError' do
        expect { subject }.to raise_error(CrystalSDK::Profile::RateLimitHitError)
      end
    end
  end

  describe '.make_request' do
    context 'without api key' do
      it 'should raise an error' do
        expect { subject.make_request(:post, 'test') }
          .to raise_error(CrystalSDK::Base::ApiKeyNotSet)
      end
    end

    context 'with api key' do
      subject { CrystalSDK::Profile.make_request(:post, 'test_endpoint') }

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
          CrystalSDK::Profile
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
          CrystalSDK::Profile
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

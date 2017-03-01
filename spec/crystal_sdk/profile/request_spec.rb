require 'spec_helper'

describe CrystalSDK::Profile::Request do
  subject { CrystalSDK::Profile::Request }

  it 'should initialize properly' do
    req = subject.new("an_id")
    expect(req.id).to eql("an_id")
  end

  describe '.from_search' do
    subject { CrystalSDK::Profile::Request.from_search(query) }
    let(:query) { { first_name: 'Test', last_name: 'Test' } }
    let(:request_type) { :post }
    let(:endpoint) { 'profiles/async' }

    context 'CrystalSDK::Api raises exception' do
      it 'should not suppress it' do
        allow(CrystalSDK::Api).to receive(:make_request)
          .with(request_type, endpoint, params: query)
          .and_raise('SomeRandomError')

        expect { subject }.to raise_error('SomeRandomError')
      end

      it 'should pass Nestful exceptions to check_for_error' do
        allow(CrystalSDK::Api).to receive(:make_request)
          .with(request_type, endpoint, params: query)
          .and_raise(Nestful::ResponseError.new(nil, nil))

        expect(CrystalSDK::Profile::Request).to receive(:check_for_error)
          .and_raise('CheckForErrorCalled')

        expect { subject }.to raise_error('CheckForErrorCalled')
      end
    end

    context 'CrystalSDK::Api returns invalid json body' do
      it 'should raise error' do
        allow(CrystalSDK::Api).to receive(:make_request)
          .with(request_type, endpoint, params: query)
          .and_return(double(body: 'pie'))

        expect { subject }.to raise_error
      end
    end

    context 'CrystalSDK::Api returns valid json body' do
      it 'should return request object' do
        allow(CrystalSDK::Api).to receive(:make_request)
          .with(request_type, endpoint, params: query)
          .and_return(double(body: '{}'))

        expect(subject).to be_kind_of(CrystalSDK::Profile::Request)
      end
    end
  end

  describe '#fetch_request_info' do
    subject { CrystalSDK::Profile::Request.new('my_id').fetch_request_info() }
    let(:request_type) { :get }
    let(:endpoint) { 'profiles/results/my_id' }

    context 'CrystalSDK::Api raises exception' do
      it 'should not suppress it' do
        allow(CrystalSDK::Api).to receive(:make_request)
          .with(request_type, endpoint)
          .and_raise('SomeRandomError')

        expect { subject }.to raise_error('SomeRandomError')
      end
    end

    context 'CrystalSDK::Api returns invalid json body' do
      it 'should raise error' do
        allow(CrystalSDK::Api).to receive(:make_request)
          .with(request_type, endpoint)
          .and_return(double(body: 'pie'))

        expect { subject }.to raise_error
      end
    end

    context 'CrystalSDK::Api returns valid json body' do
      it 'should return request object' do
        allow(CrystalSDK::Api).to receive(:make_request)
          .with(request_type, endpoint)
          .and_return(double(body: '{"something": true}'))

        expect(subject).to eql({ something: true })
      end

      context 'status is "complete"' do
        it 'should cache' do
          allow(CrystalSDK::Api).to receive(:make_request)
            .with(request_type, endpoint)
            .and_return(double(body: '{"status": "complete"}'))

          expect(subject).to eql({ status: 'complete' })

          allow(CrystalSDK::Api).to receive(:make_request)
            .with(request_type, endpoint)
            .and_return(double(body: '{"status": "failure"}'))

          expect(subject).to eql({ status: 'complete' })
        end
      end

      context 'status is "error"' do
        it 'should cache' do
          allow(CrystalSDK::Api).to receive(:make_request)
            .with(request_type, endpoint)
            .and_return(double(body: '{"status": "error"}'))

          expect(subject).to eql({ status: 'error' })

          allow(CrystalSDK::Api).to receive(:make_request)
            .with(request_type, endpoint)
            .and_return(double(body: '{"status": "failure"}'))

          expect(subject).to eql({ status: 'error' })
        end
      end
    end
  end

  describe '#fetch_status' do
    let(:request) { CrystalSDK::Profile::Request.new('my_id') }
    subject { request.fetch_status }

    it 'should pull :status from #fetch_request_info' do
      allow(request).to receive(:fetch_request_info)
        .and_return({status: 'testing'})

      expect(subject).to eql('testing')
    end
  end

  describe '#did_finish?' do
    let(:request) { CrystalSDK::Profile::Request.new('my_id') }
    subject { request.did_finish? }

    context '#fetch_status returns "complete"' do
      before(:each) do
        allow(request).to receive(:fetch_status).and_return('complete')
      end

      it { is_expected.to eql(true) }
    end

    context '#fetch_status returns "error"' do
      before(:each) do
        allow(request).to receive(:fetch_status).and_return('error')
      end

      it { is_expected.to eql(true) }
    end

    context '#fetch_status raises NotFoundError' do
      before(:each) do
        allow(request).to receive(:fetch_status)
          .and_raise(CrystalSDK::Profile::NotFoundError)
      end

      it { is_expected.to eql(true) }
    end

    context '#fetch_status raises NotAuthedError' do
      before(:each) do
        allow(request).to receive(:fetch_status)
          .and_raise(CrystalSDK::Profile::NotAuthedError.new('SomeToken'))
      end

      it { is_expected.to eql(true) }
    end

    context '#fetch_status raises an unexpected error' do
      before(:each) do
        allow(request).to receive(:fetch_status)
          .and_raise('SomeError')
      end

      it 'should not suppress it' do
        expect { subject }.to raise_error('SomeError')
      end
    end

    context '#fetch_status returns something else' do
      before(:each) do
        allow(request).to receive(:fetch_status).and_return('something')
      end

      it { is_expected.to eql(false) }
    end
  end

  describe '#did_find_profile?' do
    let(:request) { CrystalSDK::Profile::Request.new('my_id') }
    subject { request.did_find_profile? }

    context '#did_finish? is false' do
      it 'should return false' do
        allow(request).to receive(:did_finish?).and_return(false)

        expect(subject).to eql(false)
      end
    end

    context '#fetch_request_info raises NotFoundError' do
      before(:each) do
        allow(request).to receive(:fetch_request_info)
          .and_raise(CrystalSDK::Profile::NotFoundError)
      end

      it { is_expected.to eql(false) }
    end

    context '#fetch_request_info raises unexpected error' do
      before(:each) do
        allow(request).to receive(:fetch_request_info)
          .and_raise(CrystalSDK::Profile::NotAuthedError.new('SomeToken'))
      end

      it 'should not suppress it' do
        expect { subject }.to raise_error(CrystalSDK::Profile::NotAuthedError)
      end
    end

    context '#did_finish? is true' do
      before(:each) do
        allow(request).to receive(:did_finish?).and_return(true)
      end

      context '#fetch_status is not "complete"' do
        before(:each) do
          allow(request).to receive(:fetch_status).and_return('something')
        end

        it { is_expected.to eql(false) }
      end

      context '#fetch_status is "complete"' do
        before(:each) do
          allow(request).to receive(:fetch_status).and_return('complete')
        end

        context '#fetch_request_info error is not nil' do
          before(:each) do
            allow(request).to receive(:fetch_request_info).and_return({
              info: { error: 'error' }
            })
          end

          it { is_expected.to eql(false) }
        end

        context '#fetch_request_info error is nil' do
          before(:each) do
            allow(request).to receive(:fetch_request_info).and_return({
              info: { error: nil }
            })
          end

          it { is_expected.to eql(true) }
        end
      end
    end
  end

  describe '#profile_info' do
    let(:request) { CrystalSDK::Profile::Request.new('my_id') }
    subject { request.profile_info }

    context '#did_find_profile? is false' do
      before(:each) do
        allow(request).to receive(:did_find_profile?).and_return(false)
      end

      it { is_expected.to eql(nil) }
    end

    context '#did_find_profile? is true' do
      before(:each) do
        allow(request).to receive(:did_find_profile?).and_return(true)
        allow(request).to receive(:fetch_request_info).and_return({
            info: {
            some_info: 'some_info',
            deep_info: {
              info: 'deep_info'
            }
          },

          recommendations: {
            some_recs: 'some_recs',
            deep_recs: {
              recs: 'deep_recs'
            }
          }
        })
      end

      it 'should return hash with deep openstruct values' do
        expect(subject[:info].some_info).to eql('some_info')
        expect(subject[:info].deep_info.info).to eql('deep_info')
        expect(subject[:recommendations].some_recs).to eql('some_recs')
        expect(subject[:recommendations].deep_recs.recs).to eql('deep_recs')
      end
    end
  end

  describe '.check_for_error' do
    subject { CrystalSDK::Profile::Request.check_for_error(resp) }

    context '200' do
      let(:resp) do
        double(code: '200')
      end

      it 'should raise no error' do
        expect { subject }.to_not raise_error
      end
    end

    context '202' do
      let(:resp) { double(code: '202') }

      it 'should raise no error' do
        expect { subject }.to_not raise_error
      end
    end

    context '401' do
      let(:resp) { double(code: '401') }

      before(:each) do
        @orig_key = CrystalSDK.key
        CrystalSDK.key = 'SomeKey'
      end

      after(:each) do
        CrystalSDK.key = @orig_key
      end

      it 'should raise NotAuthedError' do
        expect { subject }.to raise_error(CrystalSDK::Profile::NotAuthedError)

        begin
          subject
        rescue CrystalSDK::Profile::NotAuthedError => e
          expect(e.token).to eql('SomeKey')
        end
      end
    end

    context '404' do
      let(:resp) { double(code: '404') }

      it 'should raise NotFoundError' do
        expect { subject }.to raise_error(CrystalSDK::Profile::NotFoundError)
      end
    end

    context '429' do
      let(:resp) { double(code: '429') }

      it 'should raise RateLimitHitError' do
        expect { subject }.to raise_error(CrystalSDK::Profile::RateLimitHitError)
      end
    end
  end
end

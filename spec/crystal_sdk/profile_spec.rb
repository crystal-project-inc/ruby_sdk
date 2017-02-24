require 'spec_helper'

describe CrystalSDK::Profile do
  subject { CrystalSDK::Profile }

  describe '.search' do
    subject { CrystalSDK::Profile.search(query) }
    let(:query) { { some_param: 'a_param' } }

    it 'should use the correct request' do
      resp = double(
        did_finish?: true,
        did_find_profile?: true,
        profile_info: { info: 'info', recommendations: 'recs' }
      )

      expect(CrystalSDK::Profile::Request).to receive(:from_search)
        .with(query)
        .and_return(resp)

      expect(subject.info).to eql('info')
      expect(subject.recommendations).to eql('recs')
    end

    context 'request creation raised unexpected error' do
      before(:each) do
        expect(CrystalSDK::Profile::Request).to receive(:from_search)
          .with(query)
          .and_raise('SomeRandomError')
      end

      it 'should not suppress the error' do
        expect { subject }.to raise_error('SomeRandomError')
      end
    end

    context 'request info raised expected error' do
      let(:req) { double() }

      before(:each) do
        allow(CrystalSDK::Profile::Request).to receive(:from_search)
          .with(query)
          .and_return(req)

        allow(req).to receive(:did_finish?)
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

    context 'request did not find profile' do
      before(:each) do
        allow(CrystalSDK::Profile::Request).to receive(:from_search)
          .with(query)
          .and_return(response)
      end

      let(:response) do
        double(did_finish?: true, did_find_profile?: false)
      end

      it 'should raise NotFoundError' do
        expect { subject }.to raise_error(CrystalSDK::Profile::NotFoundError)
      end
    end

    context 'request did not finish before timeout expired' do
      subject { CrystalSDK::Profile.search(query, timeout: 1) }

      before(:each) do
        allow(CrystalSDK::Profile::Request).to receive(:from_search)
          .with(query)
          .and_return(response)
      end

      let(:response) do
        double(did_finish?: false)
      end

      it 'should raise NotFoundYetError' do
        expect { subject }.to raise_error(CrystalSDK::Profile::NotFoundYetError)
      end
    end
  end

  describe '.check_for_error' do
    subject { CrystalSDK::Profile.check_for_error(resp) }

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

      it 'should raise NotAuthedError' do
        expect { subject }.to raise_error(CrystalSDK::Profile::NotAuthedError)
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

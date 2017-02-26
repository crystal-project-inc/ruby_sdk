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
          .and_raise(StandardError.new)
      end

      it 'should raise exception' do
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
      subject { CrystalSDK::Profile.search(query, timeout: 0.01) }

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

        begin
          subject
        rescue CrystalSDK::Profile::NotFoundYetError => e
          expect(e.request).to be(response)
        end
      end
    end

    context 'ApiSDK threw errors during initial request creation' do
      context '401 error' do
        before(:each) do
          allow(CrystalSDK::Api).to receive(:make_request)
            .and_raise(Nestful::ResponseError.new(nil, resp))
        end
        let(:resp) { OpenStruct.new(code: '401') }

        it 'should raise NotAuthedError' do
          expect { subject }.to raise_error(CrystalSDK::Profile::NotAuthedError)
        end
      end

      context '404 error' do
        before(:each) do
          allow(CrystalSDK::Api).to receive(:make_request)
            .and_raise(Nestful::ResponseError.new(nil, resp))
        end
        let(:resp) { OpenStruct.new(code: '404') }

        it 'should raise NotFoundError' do
          expect { subject }.to raise_error(CrystalSDK::Profile::NotFoundError)
        end
      end

      context '429 error' do
        before(:each) do
          allow(CrystalSDK::Api).to receive(:make_request)
            .and_raise(Nestful::ResponseError.new(nil, resp))
        end
        let(:resp) { OpenStruct.new(code: '429') }

        it 'should raise RateLimitHitError' do
          expect { subject }.to raise_error(CrystalSDK::Profile::RateLimitHitError)
        end
      end
    end

    context 'ApiSDK threw errors during polling' do
      context '401 error' do
        before(:each) do
          allow(CrystalSDK::Profile::Request).to receive(:from_search)
            .and_return(CrystalSDK::Profile::Request.new('some_id'))

          allow(CrystalSDK::Api).to receive(:make_request)
            .and_raise(Nestful::ResponseError.new(nil, resp))
        end
        let(:resp) { OpenStruct.new(code: '401') }

        it 'should raise NotAuthedError' do
          expect { subject }.to raise_error(CrystalSDK::Profile::NotAuthedError)
        end
      end

      context '404 error' do
        before(:each) do
          allow(CrystalSDK::Api).to receive(:make_request)
            .and_raise(Nestful::ResponseError.new(nil, resp))
        end
        let(:resp) { OpenStruct.new(code: '404') }

        it 'should raise NotFoundError' do
          expect { subject }.to raise_error(CrystalSDK::Profile::NotFoundError)
        end
      end

      context '429 error' do
        before(:each) do
          allow(CrystalSDK::Api).to receive(:make_request)
            .and_raise(Nestful::ResponseError.new(nil, resp))
        end
        let(:resp) { OpenStruct.new(code: '429') }

        it 'should raise RateLimitHitError' do
          expect { subject }.to raise_error(CrystalSDK::Profile::RateLimitHitError)
        end
      end
    end

  end
end

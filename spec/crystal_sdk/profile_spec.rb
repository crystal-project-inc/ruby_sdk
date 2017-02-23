require 'spec_helper'

describe CrystalSDK::Profile do
  subject { CrystalSDK::Profile }

  describe '.search' do
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
  end
end

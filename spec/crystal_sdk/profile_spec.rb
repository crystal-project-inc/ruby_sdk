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
    end

    context '202' do
      let(:resp) { double(body: nil, code: '202') }
    end

    context '401' do
      let(:resp) { double(body: nil, code: '401') }
    end

    context '404' do
      let(:resp) { double(body: nil, code: '404') }
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

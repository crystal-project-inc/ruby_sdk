require 'spec_helper'

describe CrystalSDK::Base do
  subject { CrystalSDK::Base }

  it { is_expected.not_to be_nil }
  it { is_expected.to respond_to(:key) }
  it { is_expected.to respond_to(:key=) }

  describe 'API_URL' do
    subject { CrystalSDK::Base::API_URL }

    it { is_expected.to include '.crystalknows.com' }
    # it { is_expected.to start_with 'https://' }
    it { is_expected.to_not end_with '/' }
  end

  describe '.key!' do
    subject { CrystalSDK::Base.key! }

    context 'no key is set' do
      before(:each) do
        allow(CrystalSDK::Base).to receive(:key).and_return(nil)
      end

      it 'should raise ApiKeyNotSet' do
        expect { subject }.to raise_error(CrystalSDK::Base::ApiKeyNotSet)
      end
    end

    context 'key is set' do
      before(:each) do
        allow(CrystalSDK::Base).to receive(:key).and_return('SomeKey')
      end

      it { is_expected.to eql(CrystalSDK::Base.key) }
    end
  end
end

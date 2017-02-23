require 'spec_helper'

describe CrystalSDK do
  it { is_expected.not_to be_nil }
  it { is_expected.to respond_to(:key) }
  it { is_expected.to respond_to(:key=) }
  it { is_expected.to respond_to(:api_key) }
  it { is_expected.to respond_to(:api_key=) }
end

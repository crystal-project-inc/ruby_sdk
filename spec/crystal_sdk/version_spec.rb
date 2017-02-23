require 'spec_helper'

describe 'CrystalSDK::VERSION' do
  subject { CrystalSDK::VERSION }

  it 'should contain 2 dots' do
    expect(subject.count('.')).to eql(2)
  end

  it 'should contain only numbers' do
    numbers = subject.split('.')

    expect { Float(numbers[0]) }.to_not raise_error
    expect { Float(numbers[1]) }.to_not raise_error
    expect { Float(numbers[2]) }.to_not raise_error
  end
end

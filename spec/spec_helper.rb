require 'bundler/setup'
Bundler.setup

require 'webmock/rspec'
require 'crystal_sdk'

WebMock.disable_net_connect!(allow_localhost: true)

RSpec.configure do |config|
  # some (optional) config here
end

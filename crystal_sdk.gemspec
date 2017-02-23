require_relative 'lib/crystal_sdk/version'

Gem::Specification.new do |s|
  s.name        = 'crystal_sdk'
  s.version     = CrystalSDK::VERSION
  s.date        = '2017-02-22'
  s.summary     = 'Access the largest and most accurate personality database!'
  s.description = 'The Enterprise SDK for https://www.crystalknows.com/ - the largest and most accurate personality database!'
  s.authors     = ['Cory Finger', 'Nicholas Picciuto']
  s.email       = 'hello@crystalknows.com'
  s.files       = ['lib/crystal_sdk.rb']
  s.homepage    =
    'https://github.com/crystal-project-inc/ruby_sdk'
  s.license     = 'Apache-2.0'

  s.files         = `git ls-files`.split($/)
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ['lib']

  s.add_dependency 'nestful', '~> 1.1'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'webmock'
end

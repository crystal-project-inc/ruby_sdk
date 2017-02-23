Gem::Specification.new do |s|
  s.name        = 'crystal_sdk'
  s.version     = '0.0.1'
  s.date        = '2017-02-22'
  s.summary     = "Access the largest and most accurate personality database!"
  s.description = "The Enterprise SDK for https://www.crystalknows.com/ - the largest and most accurate personality database!"
  s.authors     = ["Cory Finger", "Nicholas Picciuto"]
  s.email       = 'hello@crystalknows.com'
  s.files       = ["lib/crystal_sdk.rb"]
  s.homepage    =
    'https://github.com/crystal-project-inc/ruby_sdk'
  s.license     = 'Apache-2.0'

  s.add_dependency 'nestful', '~> 1.1'
end

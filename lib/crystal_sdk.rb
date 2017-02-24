require 'nestful'
require 'crystal_sdk/version'

module CrystalSDK
  autoload :Base, 'crystal_sdk/base'
  autoload :Api, 'crystal_sdk/api'
  autoload :Profile, 'crystal_sdk/profile'

  crystal_env_key = ENV['CRYSTAL_KEY']
  CrystalSDK.key = crystal_env_key if crystal_env_key

  class << self
    def key
      Base.key
    end

    def key=(value)
      Base.key = value
    end

    def api_key
      Base.key
    end

    def api_key=(value)
      Base.key = value
    end
  end
end

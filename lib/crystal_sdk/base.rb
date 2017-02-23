module CrystalSDK
  class Base
    class ApiKeyNotSet < StandardError; end
    API_URL = 'http://enterprise-api.crystalknows.com/v1'.freeze

    class << self
      attr_accessor :key

      def key!
        raise ApiKeyNotSet unless key
        key
      end
    end
  end
end

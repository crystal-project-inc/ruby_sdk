module CrystalSDK
  class Profile
    class NotFoundError < StandardError; end
    class RateLimitHitError < StandardError; end
    class UnexpectedError < StandardError; end

    class NotAuthedError < StandardError
      attr_reader :token

      def initialize(token, msg = 'Organization Token was invalid')
        @token = token
        super(msg)
      end
    end

    class NotFoundYetError < StandardError
      attr_reader :request

      def initialize(request, msg = 'Profile not found in time')
        @request = request
        super(msg)
      end
    end
  end
end

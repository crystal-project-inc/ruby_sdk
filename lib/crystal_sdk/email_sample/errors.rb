module CrystalSDK
  class EmailSample
    class NotFoundError < StandardError; end
    class UnexpectedError < StandardError; end

    class NotAuthedError < StandardError
      attr_reader :token

      def initialize(token, msg = 'Organization Token was invalid')
        @token = token
        super(msg)
      end
    end

  end
end

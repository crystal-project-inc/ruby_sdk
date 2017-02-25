require 'timeout'
require_relative 'profile/request'

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

    attr_reader :info, :recommendations

    def initialize(info, recommendations)
      @info = info
      @recommendations = recommendations
    end

    class << self
      def from_request(req)
        return nil unless req.did_find_profile?

        profile_info = req.profile_info
        Profile.new(profile_info[:info], profile_info[:recommendations])
      end

      def search(query, timeout: 30)
        request = nil

        begin
          Timeout.timeout(timeout) do
            request = Profile::Request.from_search(query)

            loop do
              sleep(2) && next unless request.did_finish?

              raise NotFoundError unless request.did_find_profile?
              return Profile.from_request(request)
            end
          end
        rescue Timeout::Error
          raise NotFoundYetError.new(request)

        rescue Nestful::ResponseError => e
          check_for_error(e.response)
          raise e
        end
      end

      def check_for_error(resp)
        raise RateLimitHitError if resp.code == '429'
        raise NotAuthedError.new(Base.key) if resp.code == '401'
        raise NotFoundError if resp.code == '404'
      end
    end
  end
end

require 'timeout'
require_relative 'profile/errors'
require_relative 'profile/request'

module CrystalSDK
  class Profile
    attr_reader :info, :recommendations, :request_id

    def initialize(info:, recommendations:, request_id:)
      @info = info
      @recommendations = recommendations
      @request_id = request_id
    end

    class << self
      def from_request(req)
        return nil unless req.did_find_profile?

        profile_info = req.profile_info
        Profile.new(info: profile_info[:info], recommendations: profile_info[:recommendations], request_id: req.id)
      end

      def search(query, timeout: 30)
        request = nil
        profile = nil

        Timeout.timeout(timeout) do
          request = Profile::Request.from_search(query)

          loop do
            sleep(2) && next unless request.did_finish?
            raise NotFoundError unless request.did_find_profile?

            profile = Profile.from_request(request)
            break
          end
        end

        profile
      rescue Timeout::Error
        raise NotFoundYetError.new(request)
      end
    end
  end
end

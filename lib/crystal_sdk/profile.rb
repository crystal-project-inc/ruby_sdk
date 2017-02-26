require 'timeout'
require_relative 'profile/errors'
require_relative 'profile/request'

module CrystalSDK
  class Profile
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
        end
      end
    end
  end
end

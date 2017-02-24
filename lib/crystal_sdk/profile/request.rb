require 'recursive-open-struct'
require 'crystal_sdk/api'

module CrystalSDK
  class Profile
    class Request
      attr_reader :id

      def initialize(id)
        @id = id
      end

      def self.from_search(query)
        resp = Api.make_request(:post, 'profile_search/async', params: query)
        body = JSON.parse(resp.body || '{}', symbolize_names: true)

        Profile::Request.new(body[:request_id])
      end

      def fetch_request_info
        return @cached_data if @cached_data

        resp = Api.make_request(:get, "results/#{@id}")
        body = resp.body ? JSON.parse(resp.body, symbolize_names: true) : nil

        if body[:status] == 'complete' || body[:status] == 'error'
          @cached_data = body
        end

        body
      end

      def fetch_status
        fetch_request_info[:status]
      end

      def did_finish?
        status = fetch_status
        status == 'complete' || status == 'error'
      end

      def did_find_profile?
        return false unless did_finish? && fetch_status == 'complete'

        info = fetch_request_info
        !info[:data][:info][:error]
      end

      def profile_info
        return nil unless did_find_profile?

        req_info = fetch_request_info
        profile_info = RecursiveOpenStruct.new(req_info[:data][:info])
        recommendations = RecursiveOpenStruct.new(req_info[:data][:recommendations])

        { info: profile_info, recommendations: recommendations }
      end
    end
  end
end

module CrystalSDK
  class Profile
    class NotFoundError < StandardError; end
    class NotFoundYetError < StandardError; end
    class NotAuthedError < StandardError; end
    class RateLimitHitError < StandardError; end
    class UnexpectedError < StandardError; end

    attr_reader :info, :recommendations

    def initialize(info, recommendations)
      @info = info
      @recommendations = recommendations
    end

    class << self
      def search(query)
        begin
          params = {
            first_name: query[:first_name],
            last_name: query[:last_name],
            email: query[:email],
            company_name: query[:company_name],
            location: query[:location],
            text_sample: query[:text_sample],
            text_type: query[:text_type]
          }

          resp = make_request(:post, 'person_search', params: params)
          body = resp.body ? JSON.parse(resp.body, symbolize_names: true) : nil

        rescue Nestful::ResponseError => e
          check_for_error(e.response)
          raise e
        end

        check_for_error(e.response)
        new(body[:info], body[:recommendations])
      end

      def check_for_error(resp)
        body = resp.body ? JSON.parse(resp.body, symbolize_names: true) : nil
        not_found = body && body[:status] == 'profile_not_found'
        not_found_yet = body && body[:status] == 'profile_not_found_yet'

        raise RateLimitHitError if resp.code == '429'
        raise NotAuthedError if resp.code == '401'
        raise NotFoundError if resp.code == '404' || not_found
        raise NotFoundYetError if resp.code == '202' || not_found_yet
        raise UnexpectedError unless resp.code == '200'
      end

      def make_request(type, endpoint, params: {}, headers: {})
        headers = headers.merge(
          'x-api-key' => Base.key!,
          'X-SDK-Version' => VERSION
        )

        opts = {
          method: type,
          headers: headers,
          params: params,
          format: :json
        }

        Nestful::Request.new("#{Base::API_URL}/#{endpoint}", opts).execute
      end
    end
  end
end

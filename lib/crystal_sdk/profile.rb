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
          resp = make_request(:post, 'person_search', params: {
            first_name: query[:first_name],
            last_name: query[:last_name],
            email: query[:email],
            company_name: query[:company_name],
            location: query[:location],
            text_sample: query[:text_sample],
            text_type: query[:text_type]
          })

          body = resp.body ? JSON.parse(resp.body, symbolize_names: true) : nil
        rescue Nestful::ResponseError => e
          resp = e.response

          raise RateLimitHitError if resp.code == '429'
          raise NotAuthedError if resp.code == '401'
          raise NotFoundError if resp.code == '404'
          raise e
        end

        not_found = body && body[:status] == 'profile_not_found'
        not_found_yet = body && body[:status] == 'profile_not_found_yet'
        raise NotFoundError if not_found
        raise NotFoundYetError if resp.code == '202' || not_found_yet
        raise UnexpectedError unless resp.code == '200'

        new(body[:info], body[:recommendations])
      end

      def make_request(type, endpoint, params: {}, headers: {})
        headers = headers.merge(
          'x-api-key' => Base.key!
        )

        Nestful::Request.new("#{Base::API_URL}/#{endpoint}", {
          method: type,
          headers: headers,
          params: params,
          format: :json
        }).execute
      end
    end
  end
end

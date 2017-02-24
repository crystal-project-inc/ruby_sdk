module CrystalSDK
  class Api
    def self.make_request(type, endpoint, params: {}, headers: {})
      headers = headers.merge(
        'X-Org-Token' => Base.key!,
        'X-Sdk-Version' => VERSION
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

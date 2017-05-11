require 'recursive-open-struct'
require 'crystal_sdk/api'

module CrystalSDK
  class EmailSample
    class Request

      def initialize(id)
        @id = id
      end

        def from_all
          begin
            resp = Api.make_request(:get, "emails/#{@id}")
          rescue Nestful::ResponseError => e
            check_for_error(e.response)
            raise e
          end

          body = JSON.parse(resp.body || '{}', symbolize_names: true)
        end

        def check_for_error(resp)
          raise EmailSample::NotAuthedError.new(Base.key) if resp.code == '401'
          raise EmailSample::NotFoundError if resp.code == '404'
        end

    end
  end
end

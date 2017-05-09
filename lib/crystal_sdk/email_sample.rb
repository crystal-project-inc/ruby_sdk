require 'timeout'
require_relative 'email_sample/errors'
require_relative 'email_sample/request'

module CrystalSDK
  class EmailSample

    def initialize()
    end

    class << self
      def all(request_id)
        sample = EmailSample::Request.new(request_id)
        sample.from_all
      end
    end
  end
end

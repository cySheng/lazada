require 'httparty'
require 'active_support/core_ext/hash'
require 'pry'
require 'pry-byebug'

require 'lazada/api/product'
require 'lazada/api/category'
require 'lazada/api/feed'
require 'lazada/api/image'
require 'lazada/api/order'
require 'lazada/api/response'
require 'lazada/api/brand'
require 'lazada/api/shipment'
require 'lazada/exceptions/lazada'

module Lazada
  class Client
    include HTTParty
    include Lazada::API::Product
    include Lazada::API::Category
    include Lazada::API::Feed
    include Lazada::API::Image
    include Lazada::API::Order
    include Lazada::API::Brand
    include Lazada::API::Shipment

    base_uri 'https://api.sellercenter.lazada.com.my'

    # Valid opts:
    # - tld: Top level domain to use (.com.my, .sg, .th...). Default: com.my
    # - debug: $stdout, Rails.logger. Log http requests
    def initialize(app_key, app_secret, opts = {})
      @app_key = app_key
      @app_secret = app_secret
      @timezone = opts[:timezone] || 'Singapore'
      @raise_exceptions = opts[:raise_exceptions] || true
      @tld = opts[:tld] || ".com.my"
      # Definitely not thread safe, as the base uri is a class variable.
      # self.class.base_uri "https://api.sellercenter.lazada#{opts[:tld]}" if opts[:tld].present?
      self.class.debug_output opts[:debug] if opts[:debug].present?
    end

    protected

    def request_url(action, options = {}, accessToken = nil)
      current_time_zone = @timezone
      timestamp = (Time.now.utc.to_f * 1000).to_i

      # options["filter"] ? filter = options.delete("filter") : filter = ""

      parameters = {
        'app_key' => @app_key,
        'sign_method' => 'sha256',
        'timestamp' => timestamp,
      }

      if accessToken != nil
        parameters["access_token"] = accessToken
      end

      parameters = parameters.merge(options.stringify_keys!) if options.present?
      parameters = Hash[parameters.sort{ |a, b| a[0] <=> b[0] }]

      sign_str = ''
      sign_str += action
      parameters.each do |k,v|
        sign_str += k.to_s()
        sign_str += v.to_s()
      end

      signature = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), @app_secret, sign_str).upcase

      "https://api.lazada#{@tld}/rest#{action}?#{parameters.to_query}&sign=#{signature}"
    end

    def process_response_errors!(response)
      return unless @raise_exceptions

      parsed_response = Lazada::API::Response.new(response)

      if parsed_response.error?
        raise Lazada::APIError.new(
          "Lazada API Error: '#{parsed_response.error_message}'",
          http_code: response.code,
          response: response.inspect,
          error_type: parsed_response.error_type,
          error_code: parsed_response.error_code,
          error_message: parsed_response.error_message,
          error_detail: parsed_response.body_error_messages,
          request_http_method: response&.request&.http_method&.to_s,
          request_uri: response&.request&.uri&.to_s
        )
      end
    end
  end

end

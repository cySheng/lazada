require 'httparty'
require 'active_support/core_ext/hash'

require 'lazada/api/product'
require 'lazada/api/category'
require 'lazada/api/feed'
require 'lazada/api/image'
require 'lazada/api/order'
require 'lazada/api/response'

module Lazada
  class Client
    include HTTParty
    include Lazada::API::Product
    include Lazada::API::Category
    include Lazada::API::Feed
    include Lazada::API::Image
    include Lazada::API::Order

    base_uri 'https://api.sellercenter.lazada.com.my'

    # Valid opts:
    # - tld: Top level domain to use (.com.my, .sg, .th...). Default: com.my
    # - debug: $stdout, Rails.logger. Log http requests
    def initialize(api_key, user_id, opts = {})
      @api_key = api_key
      @user_id = user_id

      self.class.base_uri "https://api.sellercenter.lazada#{opts[:tld]}" if opts[:tld].present?
      self.class.debug_output opts[:debug] if opts[:debug].present?
    end

    protected

    def request_url(action, options = {})
      current_time_zone = 'UTC'
      timestamp = Time.now.in_time_zone(current_time_zone).iso8601

      parameters = {
        'Action' => action,
        'Filter' => options.delete('filter'),
        'Format' => 'JSON',
        'Timestamp' => timestamp,
        'UserID' => @user_id,
        'Version' => '1.0'
      }

      parameters = parameters.merge(options) if options.present?

      parameters = Hash[parameters.sort{ |a, b| a[0] <=> b[0] }]
      params     = parameters.to_query

      signature = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), @api_key, params)
      url = "/?#{params}&Signature=#{signature}"
    end

  end
end

module Lazada
  class APIError < StandardError
    attr_reader :http_code
    attr_reader :response

    attr_reader :error_type
    attr_reader :error_code
    attr_reader :error_message
    attr_reader :error_detail

    def initialize(message = nil, params = {})
      super message

      @http_code = params[:http_code]
      @response = params[:response]

      @error_type = params[:error_type]
      @error_code = params[:error_code]
      @error_message = params[:error_message]
      @error_detail = params[:error_detail]
    end
  end
end

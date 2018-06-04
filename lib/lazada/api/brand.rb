module Lazada
  module API
    module Brand
      def get_brands(options = {})
        options["offset"] = 0 unless options["offset"]
        options["limit"] = 100 unless options["limit"]

        url = request_url('/brands/get', options)
        response = self.class.get(url)

        process_response_errors! response
        
        return response['data'] if response['code'] == "0"
        response
      end
    end
  end
end

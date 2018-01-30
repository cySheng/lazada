module Lazada
  module API
    module Brand
      def get_brands(options = {})
        options["Offset"] = 0 unless options["Offset"]
        options["Limit"] = 100 unless options["Limit"]
        p options
        url = request_url('GetBrands', options)
        response = self.class.get(url)

        return response['SuccessResponse']['Body'] if response['SuccessResponse']
        response
      end
    end
  end
end

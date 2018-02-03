module Lazada
  module API
    module Brand
      def get_brands(input = {})
        options = {}
        options["Offset"] = 0 unless input[:offset]
        options["Limit"] = 100 unless input[:limit]

        url = request_url('GetBrands', options)
        response = self.class.get(url)

        return response['SuccessResponse']['Body'] if response['SuccessResponse']
        response
      end
    end
  end
end

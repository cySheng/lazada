module Lazada
  module API
    module Brand
      def get_brands
        url = request_url('GetBrands')
        response = self.class.get(url)

        return response['SuccessResponse']['Body'] if response['SuccessResponse']
        response
      end
    end
  end
end

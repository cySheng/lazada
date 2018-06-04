module Lazada
  module API
    module Category
      def get_categories
        url = request_url('/category/tree/get')
        response = self.class.get(url)

        return response['data'] if response['code'] == "0"
        response
      end

      def get_category_attributes(primary_category_id)
        url = request_url('/category/attributes/get', 'primary_category_id' => primary_category_id)
        response = self.class.get(url)

        return response['data'] if response['code'] == "0"
        response
      end
    end
  end
end

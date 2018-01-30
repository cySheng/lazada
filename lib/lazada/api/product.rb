module Lazada
  module API
    module Product
      def get_products(status = 'all')
        url = request_url('GetProducts', { 'filter' => status })
        response = self.class.get(url)

        process_response_errors! response

        response['SuccessResponse']['Body']['Products']
      end

      def create_product(params)
        url = request_url('CreateProduct')

        params = { 'Product' => product_params(params) }

        response = self.class.post(url, body: params.to_xml(root: 'Request', skip_types: true, dasherize: false))

        Lazada::API::Response.new(response)
      end

      def update_product(params)
        url = request_url('UpdateProduct')

        params = { 'Product' => product_params(params) }

        response = self.class.post(url, body: params.to_xml(root: 'Request', skip_types: true, dasherize: false))

        process_response_errors! response

        Lazada::API::Response.new(response)
      end

      def remove_product(seller_sku)
        url = request_url('RemoveProduct')

        params = {
          'Product' => {
            'Skus' => {
              'Sku' => {
                'SellerSku' => seller_sku
              }
            }
          }
        }

        response = self.class.post(url, body: params.to_xml(root: 'Request', skip_types: true))

        Lazada::API::Response.new(response)
      end

      def get_qc_status
        url = request_url('GetQcStatus')

        response = self.class.get(url)

        process_response_errors! response

        response['SuccessResponse']['Body']['Status']
      end

      private

      def product_params(object)
        params = {}
        params['PrimaryCategory'] = object.delete("primary_category")
        params['SPUId'] = ''
        params['AssociatedSku'] = ''

        params['Skus'] = {}
        params['Skus']['Sku'] = {}
        
        params['Skus']['Sku'] = {
          'SellerSku' => object.delete("seller_sku") || object.delete("sku"),
          'size' => object.delete("variation") || object.delete("size"),
          'quantity' => object.delete("quantity"),
          'price' => object.delete("price"),
          'package_length' => object.delete("package_length") || object.delete("length"),
          'package_height' => object.delete("package_height") || object.delete("height"),
          'package_weight' => object.delete("package_weight") || object.delete("weight"),
          'package_width' => object.delete("package_width") || object.delete("width"),
          'package_content' => object.delete("package_content") || object.delete("box_content"),
          'tax_class' => object.delete("tax_class") || 'default'
        }

        params['Skus']['Sku']['Images'] = {}
        params['Skus']['Sku']['Images'].compare_by_identity

        if object[:images].present?
          object[:images].each do |image|
            url = migrate_image(image)

            params['Skus']['Sku']['Images']['Image'.dup] = url
          end
        end

        # maximum image: 8
        image_count = object[:images]&.size || 0
        (8 - image_count).times.each do |a|
          params['Skus']['Sku']['Images']['Image'.dup] = ''
        end
        
        object.delete("image") if object[:image].present?


        params['Attributes'] = {}

        params['Attributes'] = {
          'name' => object.delete("title") || object.delete("name") ,
          'name_ms' => object.delete("name_ms") || object.delete("name") || object.delete("title"),
          'description' => object.delete("description"),
          'short_description' => object.delete("short_description") || object.delete("highlights"),
          'brand' => object.delete("brand") || 'Unbranded',
          'warranty_type' => object.delete("warranty_type") || 'No Warranty',
          'model' => object.delete("model")
        }

        params['Skus']['Sku'].merge!(object)
        params['Attributes'].merge!(object)

        params
      end
    end
  end
end

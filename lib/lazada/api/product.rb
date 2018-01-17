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
        # params['Attributes'] = {
        #   'name' => object.delete("title") || object.delete("name") ,
        #   'name_ms' => object.delete("name_ms") || object.delete("name") || object.delete("title"),
        #   'short_description' => object.delete("short_description") || object.delete("description"),
        #   'brand' => object.delete("brand") || 'Unbranded',
        #   'warranty_type' => object["warranty_type"] || 'No Warranty',
        #   'model' => object.delete("model")
        # }
        params['Attributes'] = {}
        params['Attributes'].merge!(object)

        params['Skus'] = {}
        params['Skus']['Sku'] = {}
        params['Skus']['Sku'].merge!(object)

        p params

        # params['Skus']['Sku'] = {
        #   'SellerSku' => object[:seller_sku] || object[:sku],
        #   'size' => object[:variation] || object[:size],
        #   'quantity' => object[:quantity],
        #   'price' => object[:price],
        #   'package_length' => object[:package_length] || object[:length],
        #   'package_height' => object[:package_height] || object[:height],
        #   'package_weight' => object[:package_weight] || object[:weight],
        #   'package_width' => object[:package_width] || object[:width],
        #   'package_content' => object[:package_content] || object[:box_content],
        #   'tax_class' => object[:tax_class] || 'default',
        #   'status' => object[:status]
        # }

        # params['Skus']['Sku']['color'] = object[:color] if object[:color].present?
        # params['Skus']['Sku']['color_family'] = object[:color_family] if object[:color_family].present?
        # params['Skus']['Sku']['size'] = object[:size] if object[:size].present?
        # params['Skus']['Sku']['flavor'] = object[:flavor] if object[:flavor].present?
        # params['Skus']['Sku']['bedding_size_2'] = object[:bedding_size] if object[:bedding_size].present?

        # params['Skus']['Sku']['Images'] = {}
        # params['Skus']['Sku']['Images'].compare_by_identity

        # if object[:images].present?
        #   object[:images].each do |image|
        #     url = migrate_image(image)

        #     params['Skus']['Sku']['Images']['Image'.dup] = url
        #   end
        # end

        # # maximum image: 8
        # image_count = object[:images]&.size || 0
        # (8 - image_count).times.each do |a|
        #   params['Skus']['Sku']['Images']['Image'.dup] = ''
        # end

        params
      end
    end
  end
end

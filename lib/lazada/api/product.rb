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
          'short_description' => object.delete("short_description") || object.delete("description"),
          'brand' => object.delete("brand") || 'Unbranded',
          'warranty_type' => object.delete("warranty_type") || 'No Warranty',
          'model' => object.delete("model")
        }

        params['Skus']['Sku'].merge!(object)
        params['Attributes'].merge!(object)

        # params['Skus']['Sku']['size'] = object[:variation] if object[:variation].present?
        # params['Skus']['Sku']['flavor'] = object[:flavor] if object[:flavor].present?

        # params['Skus']['Sku']['status'] = object[:status] if object[:status].present?
        # params['Skus']['Sku']['color'] = object[:color] if object[:color].present?
        # params['Skus']['Sku']['color_family'] = object[:color_family] if object[:color_family].present?
        # params['Skus']['Sku']['size'] = object[:size] if object[:size].present?

        # params['Skus']['Sku']['bedding_size_2'] = object[:bedding_size] if object[:bedding_size].present?
        # params['Skus']['Sku']['storage_capacity_new'] = object[:storage_capacity_new] if object[:storage_capacity_new].present?
        # params['Skus']['Sku']['fan_dimensions'] = object[:fan_dimensions] if object[:fan_dimensions].present?
        # params['Skus']['Sku']['writing_speed'] = object[:writing_speed] if object[:writing_speed].present?
        # params['Skus']['Sku']['special_price'] = object[:special_price] if object[:special_price].present?
        # params['Skus']['Sku']['special_from_date'] = object[:special_from_date] if object[:special_from_date].present?
        # params['Skus']['Sku']['special_to_date'] = object[:special_to_date] if object[:special_to_date].present?
        # params['Skus']['Sku']['seller_promotion'] = object[:seller_promotion] if object[:seller_promotion].present?
        # params['Skus']['Sku']['fragrance_family'] = object[:fragrance_family] if object[:fragrance_family].present?
        # params['Skus']['Sku']['color_hb'] = object[:color_hb] if object[:color_hb].present?
        # params['Skus']['Sku']['units'] = object[:units] if object[:units].present?
        # params['Skus']['Sku']['holding_capacity'] = object[:holding_capacity] if object[:holding_capacity].present?
        # params['Skus']['Sku']['compatibility_by_model'] = object[:compatibility_by_model] if object[:compatibility_by_model].present?
        # params['Skus']['Sku']['powerbank_capacity'] = object[:powerbank_capacity] if object[:powerbank_capacity].present?
        
        params
      end
    end
  end
end

module Lazada
  module API
    module Product
      def get_products(params = {})
        converted_params = get_product_params(params)
        url = request_url('GetProducts', converted_params)
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

      def get_product_params(object)
        params = {}
        params["Status"] = object[:status] 
        params["CreatedAfter"] = object[:created_after] if object[:created_after].present?
        params["CreatedBefore"] = object[:created_before] if object[:created_before].present?
        params["UpdatedAfter"] = object[:updated_after] if object[:updated_after].present?
        params["UpdatedBefore"] = object[:updated_before] if object[:updated_before].present?
        params["Search"] = object[:search] if object[:search].present?
        object[:filter] = "all" unless object[:filter].present?
        params["Filter"] = object[:filter] if object[:filter].present?
        params["Limit"] = object[:limit] if object[:limit].present?
        params["Options"] = object[:options] if object[:options].present?
        params["Offset"] = object[:offset] if object[:offset].present?
        params["SkuSellerList"] = object[:sku_seller_list] if object[:sku_seller_list].present?
        params
      end

      def product_params(object)
        params = {}
        params['PrimaryCategory'] = object.delete("primary_category")
        params['SPUId'] = ''
        params['AssociatedSku'] = ''

        params['Skus'] = {}
        params['Skus'].compare_by_identity

        
        # start variant START
        object["variants"].each do |variant|
          variant_params = {}
          
          variant.delete_if { |k, v| v.empty? || v.nil? }

          variant_params['Images'] = {}
          variant_params['Images'].compare_by_identity

          if variant_params['Images'].present? 
            variant_params['Images'].each do |image|
              url = migrate_image(image)
              variant_params['Images']['Image'.dup] = url
            end
          end

          variant.delete("Images")

          params['Skus']['Sku'.dup] = variant

          # variant_params = {
          #   'SellerSku' => variant.delete("SellerSku") || variant.delete("sku"),
          #   'size' => variant.delete("variation") || variant.delete("size"),
          #   'quantity' => variant.delete("quantity"),
          #   'price' => variant.delete("price").to_f,
          #   'package_length' => variant.delete("package_length") || variant.delete("length"),
          #   'package_height' => variant.delete("package_height") || variant.delete("height"),
          #   'package_weight' => variant.delete("package_weight") || variant.delete("weight"),
          #   'package_width' => variant.delete("package_width") || variant.delete("width"),
          #   'tax_class' => variant.delete("tax_class") || 'default',
          #   'package_content' => variant.delete("package_content") || variant.delete("box_content"),
          #   "barcode_ean" => variant.delete("barcode_ean")
          # }

          # if variant["special_price"].present?
          #   variant_params.merge!({
          #     'special_price' => variant.delete("special_price"),
          #     'special_from_date' => variant.delete("special_from_date"),
          #     'special_to_date' => variant.delete("special_to_date"),
          #   })
          # else 
          #   variant.delete("special_price")
          #   variant.delete("special_from_date")
          #   variant.delete("special_to_date")
          # end

          # variant_params['coming_soon'] = variant.delete("coming_soon") if variant["coming_soon"].present?
          # variant_params['std_search_keywords'] = variant.delete("std_search_keywords") if variant["std_search_keywords"].present?
          # variant_params['seller_promotion'] = variant.delete("seller_promotion") if variant["seller_promotion"].present?
          # variant_params['color_family'] = variant.delete("color_family") if variant["color_family"].present?
          # variant_params['size'] = variant.delete("size") if variant["size"].present?
          # variant_params['flavor'] = variant.delete("flavor") if variant["flavor"].present?
          # variant_params['bedding_size_2'] = variant.delete("bedding_size") if variant["bedding_size"].present?
          # variant_params['Images'] = {}
          # variant_params['Images'].compare_by_identity


          # #TODO
          # if variant["__images__"].present?
          #   variant["__images__"].each do |image|
          #     url = migrate_image(image)

          #     variant_params['Images']['Image'.dup] = url
          #   end

          #   # maximum image: 8
          #   image_count = variant["__images__"].size || 0
          #   (8 - image_count).times.each do |a|
          #     variant['Sku']['Images']['Image'.dup] = ''
          #   end

          #   variant.delete("image") 
          # end

          # params['Skus']['Sku'.dup] = variant_params
        end

        object.delete("variants")

        # END VARIANT
        
        # params['Skus']['Sku'] = {
        #   'SellerSku' => object.delete("seller_sku") || object.delete("sku"),
        #   'size' => object.delete("variation") || object.delete("size"),
        #   'quantity' => object.delete("quantity"),
        #   'price' => object.delete("price"),
        #   'package_length' => object.delete("package_length") || object.delete("length"),
        #   'package_height' => object.delete("package_height") || object.delete("height"),
        #   'package_weight' => object.delete("package_weight") || object.delete("weight"),
        #   'package_width' => object.delete("package_width") || object.delete("width"),
        #   'package_content' => object.delete("package_content") || object.delete("box_content"),
        #   'tax_class' => object.delete("tax_class") || 'default'
        # }

        # if object["special_price"].present?
        #   params['Skus']['Sku'].merge!({
        #     'special_price' => object["special_price"],
        #     'special_from_date' => object["special_from_date"],
        #     'special_to_date' => object["special_to_date"],
        #   })
        # end

        # params['Skus']['Sku']['color_family'] = object["color_family"] if object["color_family"].present?
        # params['Skus']['Sku']['size'] = object["size"] if object["size"].present?
        # params['Skus']['Sku']['flavor'] = object["flavor"] if object["flavor"].present?
        # params['Skus']['Sku']['bedding_size_2'] = object["bedding_size"] if object["bedding_size"].present?
        # params['Skus']['Sku']['Images'] = {}
        # params['Skus']['Sku']['Images'].compare_by_identity

        # if object[:images].present?
        #   object[:images].each do |image|
        #     url = migrate_image(image)

        #     params['Skus']['Sku']['Images']['Image'.dup] = url
        #   end
        #   image_count = object[:images].size || 0
        #   (8 - image_count).times.each do |a|
        #     params['Skus']['Sku']['Images']['Image'.dup] = ''
        #   end
        # end

        # maximum image: 8

        
        # object.delete("image") if object[:image].present?


        params['Attributes'] = {}

        params['Attributes'] = {
          'name' => object.delete("title") || object.delete("name") ,
          'name_ms' => object.delete("name_ms") || object.delete("name") || object.delete("title"),
          'description' => object.delete("description"),
          'short_description' => object.delete("short_description") || object.delete("highlights"),
          'brand' => object.delete("brand") || 'Unbranded',
          'warranty_type' => object.delete("warranty_type") || 'No Warranty',
          'model' => object.delete("model"),
          'package_content' => object.delete("package_content") || object.delete("box_content")
        }

        params['Attributes'].merge!(object)
        params['Attributes'].delete("2_in_1_type") 
        params
      end
    end
  end
end

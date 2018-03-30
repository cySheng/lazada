module Lazada
  module API
    module Product
      def get_products(status = 'all')
        params = get_product_params(status)
        url = request_url('GetProducts', params)
        response = self.class.get(url)

        process_response_errors! response

        response['SuccessResponse']['Body']['Products']
      end

      def create_product(params)
        x = {"title"=>"asdfasdf",
         "sku"=>"asdfasdf",
         "description"=>"<p>sdfadfasdfadsf</p>",
         "variants"=>
          [{"color_family"=>"Black",
            "package_content"=>"asdfasdfasdf",
            "SellerSku"=>"asdfasdfasdf",
            "barcode_ean"=>"",
            "quantity"=>"",
            "price"=>"1",
            "special_price"=>"",
            "special_from_date"=>"2018-03-29",
            "special_to_date"=>"2018-03-29",
            "seller_promotion"=>"",
            "package_weight"=>"1",
            "package_length"=>"1",
            "package_width"=>"1",
            "package_height"=>"1",
            "__images__"=>"",
            "tax_class"=>"tax 6",
            "std_search_keywords"=>"",
            "coming_soon"=>"2018-03-29"}],
         "box_content"=>"asdfadsfasdf",
         "brand"=>"test carmen",
         "model"=>"asdfasdf",
         "warranty_type"=>"Local Manufacturer Warranty",
         "warranty"=>"1 Month",
         "name"=>"asdfasdf",
         "short_description"=>"<p>asdfasdf</p>",
         "processor_type"=>"Single-core",
         "display_size"=>"3",
         "wireless_connectivity"=>"Cellular (3G/4G)",
         "io_ports"=>"VGA",
         "software_offerings"=>"Skype",
         "touchpad"=>"No",
         "ac_adapter"=>"Yes",
         "graphics_memory_new"=>"8GB & Up",
         "battery_life"=>"21 hour and up",
         "camera_front"=>"2-3MP",
         "hdd_size"=>"3.5TB",
         "cpu_speed"=>"4-5 Ghz",
         "cpu_brand"=>"Xeon",
         "operating_system"=>"Windows",
         "graphics_card"=>"Integrated",
         "system_memory_new"=>"16GB",
         "2_in_1_type"=>["detachable"],
         "name_ms"=>"asdfasdfasdf",
         "delivery_option_standard"=>"Yes",
         "delivery_option_economy"=>"Yes",
         "delivery_option_express"=>"Yes",
         "Hazmat"=>["Battery"],
         "primary_category"=>"8863",
         "highlights"=>"<p>sdfdasfsdf</p>\n"}
        params = x
        url = request_url('CreateProduct')

        binding.pry

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
          
          variant_params = {
            'SellerSku' => variant.delete("SellerSku") || variant.delete("sku"),
            'size' => variant.delete("variation") || variant.delete("size"),
            'quantity' => variant.delete("quantity"),
            'price' => variant.delete("price").to_f,
            'package_length' => variant.delete("package_length") || variant.delete("length"),
            'package_height' => variant.delete("package_height") || variant.delete("height"),
            'package_weight' => variant.delete("package_weight") || variant.delete("weight"),
            'package_width' => variant.delete("package_width") || variant.delete("width"),
            'tax_class' => variant.delete("tax_class") || 'default',
            'package_content' => variant.delete("package_content") || variant.delete("box_content"),
            "barcode_ean" => variant.delete("barcode_ean")
          }

          if variant["special_price"].present?
            variant_params.merge!({
              'special_price' => variant.delete("special_price"),
              'special_from_date' => variant.delete("special_from_date"),
              'special_to_date' => variant.delete("special_to_date"),
            })
          else 
            variant.delete("special_price")
            variant.delete("special_from_date")
            variant.delete("special_to_date")
          end

          variant_params['coming_soon'] = variant.delete("coming_soon") if variant["coming_soon"].present?
          variant_params['std_search_keywords'] = variant.delete("std_search_keywords") if variant["std_search_keywords"].present?
          variant_params['seller_promotion'] = variant.delete("seller_promotion") if variant["seller_promotion"].present?
          variant_params['color_family'] = variant.delete("color_family") if variant["color_family"].present?
          variant_params['size'] = variant.delete("size") if variant["size"].present?
          variant_params['flavor'] = variant.delete("flavor") if variant["flavor"].present?
          variant_params['bedding_size_2'] = variant.delete("bedding_size") if variant["bedding_size"].present?
          variant_params['Images'] = {}
          variant_params['Images'].compare_by_identity


          #TODO
          if variant["__images__"].present?
            variant["__images__"].each do |image|
              url = migrate_image(image)

              variant_params['Images']['Image'.dup] = url
            end

            # maximum image: 8
            image_count = variant["__images__"].size || 0
            (8 - image_count).times.each do |a|
              variant['Sku']['Images']['Image'.dup] = ''
            end

            variant.delete("image") 
          end

          params['Skus']['Sku'.dup] = variant_params
        end

        object.delete["variants"]

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
        params
      end
    end
  end
end

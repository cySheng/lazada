module Lazada
  module API
    module Product
      def get_products(params = {}, access_token)
        converted_params = get_product_params(params)
        url = request_url('/products/get', converted_params, access_token)
        response = self.class.get(url)

        process_response_errors! response

        response['data']['products']
      end

      def create_product(params, access_token)
        params = { 'Product' => product_params(params) }
        url = request_url('/product/create', options={"payload": params.to_xml(root: 'Request', skip_types: true, dasherize: false)}, access_token)

        response = self.class.post(url)

        Lazada::API::Response.new(response)
      end

      def update_product(params, access_token)
        params = { 'Product' => product_params(params) }
        url = request_url('/product/update', options={"payload": params.to_xml(root: 'Request', skip_types: true, dasherize: false)}, access_token)
        response = self.class.post(url)

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
        params["create_after"] = object[:created_after] if object[:created_after].present?
        params["create_before"] = object[:created_before] if object[:created_before].present?
        params["update_after"] = object[:updated_after] if object[:updated_after].present?
        params["update_before"] = object[:updated_before] if object[:updated_before].present?
        params["search"] = object[:search] if object[:search].present?
        object[:filter] = "all" unless object[:filter].present?
        params["filter"] = object[:filter] if object[:filter].present?
        params["limit"] = object[:limit] if object[:limit].present?
        params["options"] = object[:options] if object[:options].present?
        params["offset"] = object[:offset] if object[:offset].present?
        params["sku_seller_list"] = object[:sku_seller_list] if object[:sku_seller_list].present?
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

          variant.delete_if { |k, v| v.to_s.empty? || v.nil? }

          variant_params['Images'] = {}
          variant_params['Images'].compare_by_identity

          if variant['Images'].present?
            variant['Images'].each do |image|
              url = migrate_image(image)
              variant_params['Images']['Image'.dup] = url
            end
          end

          variant.delete("Images")

          variant.merge!(variant_params)

          params['Skus']['Sku'.dup] = {
            "SellerSku": variant["SellerSku"],
            "price": variant["price"],
            "quantity": variant["quantity"],
            "special_price": variant["special_price"],
            "special_from_date": variant["special_from_date"],
            "special_to_date": variant["special_to_date"],
            "package_height": variant["package_height"],
            "package_length": variant["package_length"],
            "package_width": variant["package_width"],
            "package_weight": variant["package_weight"],
            "package_content": variant["package_content"]
          }
        end
        object.delete("variants")

        params['attributes'] = {}

        params['attributes'] = {
          'name' => object.delete("title") || object.delete("name"),
          'description' => object.delete("description"),
          'short_description' => object.delete("short_description") || object.delete("highlights"),
          'brand' => object.delete("brand") || 'Unbranded',
          'model' => object.delete("model"),
          'warranty_type' => object.delete("warranty_type") || 'No Warranty'
        }

        params['attributes'].delete("2_in_1_type")
        params
      end
    end
  end
end

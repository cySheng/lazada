module Lazada
  module API
    module Order
      def get_orders(options = {})
        params = {}
        params['Status'] = options[:status] if options[:status].present?
        params['CreatedAfter'] = options[:created_after].iso8601 if options[:created_after].present?

        url = request_url('GetOrders', params)
        response = self.class.get(url)

        process_response_errors! response

        return response['SuccessResponse']['Body']['Orders']
      end

      def get_order(id)
        url = request_url('GetOrder', { 'OrderId' => id })
        response = self.class.get(url)

        process_response_errors! response

        return response['SuccessResponse']['Body']['Orders']
      end

      def get_order_items(id)
        url = request_url('GetOrderItems', { 'OrderId' => id })
        response = self.class.get(url)

        process_response_errors! response

        return response['SuccessResponse']['Body']['OrderItems']
      end

      def get_multiple_order_items(ids_list)
        raise Lazada::LazadaError("IDs list must be an Array of integers or strings") unless ids_list.is_a?(Array)

        url = request_url('GetMultipleOrderItems', { 'OrderIdList' => "[#{ids_list.join(',')}]"})
        response = self.class.get(url)

        process_response_errors! response

        return response['SuccessResponse']['Body']['Orders']
      end
    end
  end
end

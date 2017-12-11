module Lazada
  module API
    module Order
      def get_orders(options = {})
        url = request_url('GetOrders')
        params = {}
        params['Status'] = options[:status] if options[:status].present?
        params['CreatedAfter'] = options[:created_after] if options[:created_after]

        url = request_url('GetOrders', params) if params.present?
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
    end
  end
end

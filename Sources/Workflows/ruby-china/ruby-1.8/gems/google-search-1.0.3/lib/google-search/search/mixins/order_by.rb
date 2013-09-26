
module Google
  class Search
    module OrderBy
      
      #--
      # Constants
      #++

      ORDER_BY = :relevance, :date

      ##
      # Order by. Defaults to :relevance
      #
      #  - :relevance
      #  - :date
      #

      attr_accessor :order_by

      #:nodoc:

      def initialize options = {}, &block
        @order_by = options.delete :order_by
        super
      end

      #:nodoc:

      def get_uri_params
        validate(:order_by) { |order| order.nil? || ORDER_BY.include?(order) }
        super + [[:scoring, order_by ? 'd' : nil]]
      end
    end
  end
end
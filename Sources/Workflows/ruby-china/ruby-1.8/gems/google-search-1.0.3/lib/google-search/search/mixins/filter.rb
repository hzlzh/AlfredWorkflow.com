
module Google
  class Search
    module Filter
      
      ##
      # Weither or not to filter duplicate results.
      # Defaults to true.
      
      attr_accessor :filter

      #:nodoc:

      def initialize options = {}, &block
        @filter = options.delete(:filter) || 1
        super
      end

      #:nodoc:

      def get_uri_params
        super + [[:filter, filter ? 1 : 0]]
      end
    end
  end
end

module Google
  class Search
    class Patent < self
      
      #--
      # Mixins
      #++
      
      include OrderBy
      
      ##
      # When nil all parents are returned.
      # When true only issued will be returned,
      # otherwise when false only filed but NOT
      # issued patents will be returned.
      
      attr_accessor :issued_only
      
      #:nodoc:
      
      def initialize options = {}, &block
        @issued_only = options.delete :issued_only
        super
      end
      
      #:nodoc:
      
      def get_uri_params
        super + [
          [:as_psrg, issued_only ? 1 : nil],
          [:as_psra, issued_only === false ? 1 : nil]
          ]
      end
    end
  end
end
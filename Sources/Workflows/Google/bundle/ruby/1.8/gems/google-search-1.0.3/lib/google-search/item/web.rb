
module Google
  class Search
    class Item
      class Web < self
        
        ##
        # Cached uri.
        
        attr_reader :cache_uri
        
        ##
        # Initialize with _hash_.

        def initialize hash
          super
          @cache_uri = hash['cacheUrl']
        end
      end
    end
  end
end
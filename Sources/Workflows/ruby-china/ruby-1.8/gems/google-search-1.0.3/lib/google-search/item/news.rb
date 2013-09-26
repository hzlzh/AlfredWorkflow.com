
module Google
  class Search
    class Item
      class News < self
        
        ##
        # Published DateTime.
        
        attr_reader :published
        
        ##
        # Publisher.
        
        attr_reader :publisher
        
        ##
        # Location.
        
        attr_reader :location
        
        ##
        # Language.
      
        attr_reader :language
        
        ##
        # Redirect uri.
        
        attr_reader :redirect_uri
        
        ##
        # Initialize with _hash_.

        def initialize hash
          super
          @location = hash['location']
          @published = DateTime.parse hash['publishedDate']
          @language = hash['language']
          @publisher = hash['publisher']
          @redirect_uri = hash['signedRedirectUrl']
        end
      end
    end
  end
end
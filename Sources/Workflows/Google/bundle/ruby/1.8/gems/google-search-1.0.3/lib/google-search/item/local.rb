
module Google
  class Search
    class Item
      class Local < self
        
        ##
        # Country.
        
        attr_reader :country
        
        ##
        # Region.
        
        attr_reader :region
        
        ##
        # City.
        
        attr_reader :city
        
        ##
        # Type.
        
        attr_reader :type
        
        ##
        # Accuracy.
        
        attr_reader :accuracy
        
        ##
        # Max age in seconds.
        
        attr_reader :max_age
        
        ##
        # Google maps directions uri.
        
        attr_reader :directions_uri
        
        ##
        # Google maps directions to here uri.
        
        attr_reader :directions_to_here_uri
        
        ##
        # Google maps directions from here uri.
        
        attr_reader :directions_from_here_uri
        
        ##
        # Longitude float.
        
        attr_reader :long
        
        ##
        # Latitude float.
        
        attr_reader :lat
        
        ##
        # Viewport mode.
        
        attr_reader :viewport_mode
        
        ##
        # Phone numbers array.
        
        attr_reader :phone_numbers
        
        ##
        # Street address.
        
        attr_reader :street_address
        
        ##
        # Address lines array.
        
        attr_reader :address_lines
        
        ##
        # Initialize with _hash_.

        def initialize hash
          super
          @country = hash['country']
          @region = hash['region']
          @city = hash['city']
          @type = hash['listingType']
          @accuracy = hash['accuracy'].to_i
          @max_age = hash['maxAge']
          @directions_uri = hash['ddUrl']
          @directions_to_here_uri = hash['ddUrlToHere']
          @directions_from_here_uri = hash['ddUrlFromHere']
          @thumbnail_uri = hash['staticMapUrl']
          @long = hash['lng'].to_f
          @lat = hash['lat'].to_f
          @viewport_mode = hash['viewportmode']
          @phone_numbers = hash['phoneNumbers'].map { |phone| phone['number'] }
          @street_address = hash['streetAddress']
          @address_lines = hash['addressLines']
        end
      end
    end
  end
end
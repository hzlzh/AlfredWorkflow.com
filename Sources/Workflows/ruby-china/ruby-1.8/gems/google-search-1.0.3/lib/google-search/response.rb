
module Google
  class Search
    class Response
      
      #--
      # Mixins
      #++
      
      include Enumerable
      
      ##
      # Response status code.
      
      attr_reader :status
      
      ##
      # Response details.
      
      attr_reader :details
      
      ##
      # Raw JSON string.
      
      attr_accessor :raw
      
      ##
      # Hash parsed from raw JSON string.
      
      attr_reader :hash
      
      ##
      # Items populated by the JSON hash.
      
      attr_reader :items
      
      ##
      # Estimated number of results.
      
      attr_reader :estimated_count
      
      ##
      # Current page index.
      
      attr_reader :page
      
      ##
      # Size of response.
      
      attr_reader :size

      ##
      # Initialize with _hash_.
      
      def initialize hash
        @page = 0
        @hash = hash
        @size = (hash['responseSize'] || :large).to_sym
        @items = []
        @status = hash['responseStatus']
        @details = hash['responseDetails']
        if valid?
          if hash['responseData'].include? 'cursor'
            @estimated_count = hash['responseData']['cursor']['estimatedResultCount'].to_i
            @page = hash['responseData']['cursor']['currentPageIndex'].to_i
          end
          @hash['responseData']['results'].each_with_index do |result, i|
            item_class = Google::Search::Item.class_for result['GsearchResultClass']
            result['index'] = i + Google::Search.size_for(size) * page
            items << item_class.new(result)
          end
        end
      end
      
      ##
      # Iterate each item with _block_.
      
      def each_item &block
        items.each { |item| yield item }
      end
      alias :each :each_item
      
      ##
      # Check if the response is valid.
      
      def valid?
        hash['responseStatus'] == 200
      end
      
    end
  end
end
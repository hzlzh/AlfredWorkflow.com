
module Google
  class Search
    class Item
      
      ##
      # Index.
      
      attr_reader :index
      
      ##
      # Unformatted page title.
      
      attr_reader :title
      
      ##
      # Absolute uri.
      
      attr_reader :uri
      
      ##
      # Visible uri.
      
      attr_reader :visible_uri
      
      ##
      # Thumbnail uri.
      
      attr_reader :thumbnail_uri
      
      ##
      # Thumbnail width in pixels.
      
      attr_reader :thumbnail_width
      
      ##
      # Thumbnail height in pixels.
      
      attr_reader :thumbnail_height
      
      ##
      # Contents.
      
      attr_reader :content
      
      ##
      # Initialize with _hash_.

      def initialize hash
        @index = hash['index']
        @title = hash['titleNoFormatting'] || hash['title']
        @uri = hash['unescapedUrl'] || hash['url'] || hash['postUrl']
        @content = hash['contentNoFormatting'] || hash['content']
        @thumbnail_uri = hash['tbUrl']
        @thumbnail_width = hash['tbWidth'].to_i
        @thumbnail_height = hash['tbHeight'].to_i
        @visible_uri = hash['visibleUrl']
      end
      
      ##
      # Return class for _google_class_ string formatted
      # as 'GwebSearch', 'GbookSearch', etc.
      
      def self.class_for google_class
        case google_class
        when 'GwebSearch'    ; Web
        when 'GlocalSearch'  ; Local
        when 'GbookSearch'   ; Book
        when 'GimageSearch'  ; Image
        when 'GvideoSearch'  ; Video
        when 'GpatentSearch' ; Patent
        when 'GnewsSearch'   ; News
        when 'GblogSearch'   ; Blog
        end
      end
    end
  end
end

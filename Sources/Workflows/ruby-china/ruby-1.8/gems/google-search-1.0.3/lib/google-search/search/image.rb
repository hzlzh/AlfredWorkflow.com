
module Google
  class Search
    class Image < self
      
      #--
      # Mixins
      #++
      
      include SafetyLevel
      
      #--
      # Constants
      #++
      
      SIZES = :icon, :small, :medium, :large, :xlarge, :xxlarge, :huge
      TYPES = :face, :photo, :clipart, :lineart
      EXTENSIONS = :jpg, :png, :gif, :bmp
      
      ##
      # Image size:
      #
      #  - :icon
      #  - :small
      #  - :medium
      #  - :large
      #  - :xlarge
      #  - :xxlarge
      #  - :huge
      #
      
      attr_accessor :image_size
      
      ##
      # Image type:
      #
      #  - :face
      #  - :photo
      #  - :clipart
      #  - :lineart
      #
      
      attr_accessor :image_type
      
      ##
      # File type:
      #
      #  - :jpg
      #  - :gif
      #  - :png
      #  - :bmp
      #
      
      attr_accessor :file_type
      
      ##
      # Image color.
      
      attr_accessor :color
      
      ##
      # Specific uri to fetch images from.
      
      attr_accessor :uri
      
      #:nodoc:
      
      def initialize options = {}, &block
        @color = options.delete :color
        @image_size = options.delete :image_size
        @image_type = options.delete :image_type
        @file_type = options.delete :file_type
        super
      end
      
      #:nodoc:
      
      def get_uri_params
        validate(:image_size) { |size| size.nil? || size.is_a?(Array) || SIZES.include?(size) }
        validate(:image_type) { |type| type.nil? || TYPES.include?(type) }
        validate(:file_type) { |ext| ext.nil? || EXTENSIONS.include?(ext) }
        super + [
          [:safe, safety_level],
          [:imgsz, image_size.is_a?(Array) ? image_size.join('|') : image_size],
          [:imgcolor, color],
          [:imgtype, image_type],
          [:as_filetype, file_type],
          [:as_sitesearch, uri]
          ]
      end
    end
  end
end
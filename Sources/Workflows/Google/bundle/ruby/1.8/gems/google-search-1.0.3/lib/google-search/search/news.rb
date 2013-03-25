
module Google
  class Search
    class News < self
      
      #--
      # Mixins
      #++
      
      include OrderBy
      
      #--
      # Constants
      #++
      
      TOPICS = :headlines, :world, :business, :nation, :science, 
               :elections, :politics, :entertainment, :sports, :health

      ##
      # Relative to city, state, province, zipcode, etc.
      
      attr_accessor :relative_to
      
      ##
      # Topic:
      #
      #  - :headlines
      #  - :world
      #  - :business
      #  - :nation
      #  - :science
      #  - :elections
      #  - :politics
      #  - :entertainment
      #  - :sports
      #  - :health
      #
      
      attr_accessor :topic
      
      ##
      # Edition, such as :us, :uk, :fr_ca, etc.
      
      attr_accessor :edition
      
      #:nodoc:
      
      def initialize options = {}, &block
        @relative_to = options.delete :relative_to
        @edition = options.delete :edition
        super
      end
      
      #:nodoc:
      
      def get_uri_params
        validate(:topic) { |topic| topic.nil? || TOPICS.include?(topic) }
        super + [
          [:geo, relative_to],
          [:topic, topic],
          [:ned, edition]
          ]
      end
    end
  end
end
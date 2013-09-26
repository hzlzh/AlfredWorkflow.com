
module Google
  class Search
    class Item
      class Book < self
        
        ##
        # Book id.
        
        attr_reader :id
        
        ##
        # Author name(s).
        
        attr_reader :author
        
        ##
        # Published year.
        
        attr_reader :published_year
        
        ##
        # Page count.
        
        attr_reader :pages
        
        ##
        # Initialize with _hash_.

        def initialize hash
          super
          @author = hash['authors']
          @published_year = hash['publishedYear'].to_i
          @id = hash['bookId']
          @pages = hash['pageCount'].to_i
        end
      end
    end
  end
end

module Google
  class Search
    class Video < self
      
      #--
      # Mixins
      #++
      
      include OrderBy
      include Filter

    end
  end
end
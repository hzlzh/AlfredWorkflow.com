
module Google
  class Search
    class Web < self
      
      #--
      # Mixins
      #++
      
      include Filter
      include SafetyLevel
      
    end
  end
end
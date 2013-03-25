
module Google
  class Search
    module SafetyLevel
      
      #--
      # Constants
      #++
      
      SAFETY_LEVELS = :active, :moderate, :off
      
      ##
      # Safety level:
      #
      #   - :active | :high
      #   - :moderate | :medium
      #   - :off
      #
      
      attr_accessor :safety_level
      
      #:nodoc:
      
      def initialize options = {}, &block
        @safety_level = options.delete :safety_level
        super
      end
      
      #:nodoc:
      
      def get_uri_params
        @safety_level = :off if @safety_level == :none
        @safety_level = :moderate if @safety_level == :medium
        @safety_level = :active if @safety_level == :high
        validate(:safety_level) { |level| level.nil? || SAFETY_LEVELS.include?(level) }
        super + [[:safe, safety_level]]
      end
    end
  end
end
module Dropbox
  module API
    class Delta
      attr_reader :cursor, :entries
      def initialize(cursor, entries)
        @cursor  = cursor
        @entries = entries
      end
    end
  end
end

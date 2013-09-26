
module Google
  class Search
    class Item
      class Patent < self
        
        ##
        # Patent id.
        
        attr_reader :id
        
        ##
        # Patent status.
        
        attr_reader :status
        
        ##
        # Assignee.
        
        attr_reader :assignee
        
        ##
        # Application DateTime.
        
        attr_reader :application_date
        
        ##
        # Initialize with _hash_.

        def initialize hash
          super
          @id = hash['patentNumber'].to_i
          @application_date = DateTime.parse hash['applicationDate']
          @assignee = hash['assignee']
          @status = hash['patentStatus']
        end
      end
    end
  end
end
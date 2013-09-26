
module Google
  class Search
    
    #--
    # Mixins
    #++
    
    include Enumerable
    
    #--
    # Constants
    #++
    
    URI = 'http://www.google.com/uds'
    
    #--
    # Exceptions
    #++
    
    class Error < StandardError; end
    
    ##
    # Version. Defaults to 1.0
    
    attr_accessor :version
    
    ##
    # Search type symbol.
    
    attr_accessor :type
    
    ##
    # Offset. Defaults to 0
    
    attr_accessor :offset
    
    ##
    # Language. Defaults to :en
    
    attr_accessor :language
    
    ##
    # Weither or not a search request has been sent.
    
    attr_accessor :sent
    
    ##
    # Query. Defaults to nil
    
    attr_accessor :query
    
    ##
    # API Key. Defaults to :notsupplied
    
    attr_accessor :api_key
    
    ##
    # Size. Defaults to :large
    #
    #  - :small = 4
    #  - :large = 8
    #
    
    attr_accessor :size
    
    ##
    # Additional options. All those listed above
    # are deleted. The remaining represent query
    # string key / value pairs.
    
    attr_reader :options
    
    ##
    # Initialize search _type_ with _options_. Optionally
    # a block may be passed, and the Search instance will 
    # be yielded to it.
    
    def initialize options = {}, &block
      @type = self.class.to_s.split('::').last.downcase.to_sym
      @version = options.delete(:version) || 1.0
      @offset = options.delete(:offset) || 0
      @size = options.delete(:size) || :large
      @language = options.delete(:language) || :en
      @query = options.delete(:query)
      @api_key = options.delete(:api_key) || :notsupplied
      @options = options
      raise Error, 'Do not initialize Google::Search; Use a subclass such as Google::Search::Web' if @type == :search
      yield self if block
    end
    
    ##
    # Set a response _block_ which is called every time
    # #get_response is called. Useful for reporting etc.
    
    def each_response &block
      @each_response = block
    end
    
    ##
    # Iterate each item with _block_.
    
    def each_item &block
      response = self.next.response
      if response.valid?
        response.each { |item| yield item }
        each_item &block
      end
    end
    alias :each :each_item
    
    ##
    # Return all items.
    
    def all_items
      select { true }
    end
    alias :all :all_items
    
    ##
    # Return uri.
    
    def get_uri
      URI + "/G#{@type}Search?" + 
        (get_uri_params + options.to_a).
          map { |key, value| "#{key}=#{Search.url_encode(value)}" unless value.nil? }.compact.join('&')
    end
    
    #:nodoc:
    
    def get_uri_params
      validate(:query) { |query| query.respond_to?(:to_str) && !query.to_str.empty? }
      validate(:version) { |version| Numeric === version }
      [[:start, offset],
      [:rsz, size],
      [:hl, language],
      [:key, api_key],
      [:v, version],
      [:q, query]]
    end
    
    ##
    # Prepare for next request.
    
    def next
      @offset += Search.size_for(size) if sent
      self
    end
    
    ##
    # Return raw JSON response string.
    
    def get_raw
      @sent = true
      open(get_uri).read
    end
    
    ##
    # Return hash parsed from the raw JSON response.
    
    def get_hash
      Search.json_decode get_raw
    end
    
    ##
    # Return Response object wrapping the JSON
    # response hash.
    
    def get_response
      raw = get_raw
      hash = Search.json_decode raw
      hash['responseSize'] = size
      response = Response.new hash
      response.raw = raw
      @each_response.call response if @each_response
      response
    end
    alias :response :get_response
    
    ##
    # Return int for size _sym_.
    
    def self.size_for sym
      { :small => 4,
        :large => 8 }[sym]
    end
    
    #:nodoc:
    
    def validate meth, &block
      value = send meth
      raise Error, "invalid #{type} #{meth} #{value.inspect}", caller unless yield value
    end
    
    ##
    # Decode JSON _string_.
    
    def self.json_decode string
      JSON.parse string
    end
    
    ##
    # Url encode _string_.
    
    def self.url_encode string
      string.to_s.gsub(/([^ a-zA-Z0-9_.-]+)/) {
        '%' + $1.unpack('H2' * $1.bytesize).join('%').upcase
      }.tr(' ', '+')
    end
    
  end
end

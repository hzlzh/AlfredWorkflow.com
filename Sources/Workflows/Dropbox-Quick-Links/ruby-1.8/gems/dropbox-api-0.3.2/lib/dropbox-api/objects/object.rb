module Dropbox
  module API

    class Object < Hashie::Mash
      attr_accessor :client

      def self.init(response, client)
        instance = self.new(response)
        instance.client = client
        instance
      end

      def self.resolve_class(hash)
        hash['is_dir'] == true ? Dropbox::API::Dir : Dropbox::API::File
      end

      def self.convert(array_or_object, client)
        if array_or_object.is_a?(Array)
          array_or_object.collect do |item|
            resolve_class(item).init(item, client)
          end
        else
          resolve_class(array_or_object).init(array_or_object, client)
        end
      end

      # Kill off the ability for recursive conversion
      def deep_update(other_hash)
        other_hash.each_pair do |k,v|
          key = convert_key(k)
          regular_writer(key, convert_value(v, true))
        end
        self
      end

    end

  end
end

module Dropbox
  module API

    module Fileops

      def copy(to, options = {})
        response = client.raw.copy({ :from_path => self.path, :to_path => to }.merge(options))
        self.update response
      end

      def move(to, options = {})
        response = client.raw.move({ :from_path => self.path, :to_path => to }.merge(options))
        self.update response
      end

      def destroy(options = {})
        response = client.raw.delete({ :path => self.path }.merge(options))
        self.update response
      end

      def path
        self['path'].sub(/^\//, '')
      end

      def share_url(options = {})
        response = client.raw.shares({ :path => self.path }.merge(options))
        Dropbox::API::Object.init(response, client)
      end

    end

  end
end

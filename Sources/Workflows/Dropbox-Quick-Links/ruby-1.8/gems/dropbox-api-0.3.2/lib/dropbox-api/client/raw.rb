module Dropbox
  module API

    class Raw

      attr_accessor :connection

      def initialize(options = {})
        @connection = options[:connection]
      end

      def self.add_method(method, action, options = {})
        # Add the default root bit, but allow it to be disabled by a config option
        root = options[:root] == false ? '' : "options[:root] ||= Dropbox::API::Config.mode"
        self.class_eval <<-STR
          def #{options[:as] || action}(options = {})
            #{root}
            request(:#{options[:endpoint] || 'main'}, :#{method}, "#{action}", options)
          end
        STR
      end

      def request(endpoint, method, action, data = {})
        action.sub! ':root', data.delete(:root) if action.match ':root'
        action.sub! ':path', Dropbox::API::Util.escape(data.delete(:path)) if action.match ':path'
        action = Dropbox::API::Util.remove_double_slashes(action)
        connection.send(method, endpoint, action, data)
      end

      add_method :get,  "/account/info",           :as => 'account', :root => false

      add_method :get,  "/metadata/:root/:path",   :as => 'metadata'
      add_method :post, "/delta",                  :as => 'delta', :root => false
      add_method :get,  "/revisions/:root/:path",  :as => 'revisions'
      add_method :post, "/restore/:root/:path",    :as => 'restore'
      add_method :get,  "/search/:root/:path",     :as => 'search'
      add_method :post, "/shares/:root/:path",     :as => 'shares'
      add_method :post, "/media/:root/:path",      :as => 'media'

      add_method :get_raw, "/thumbnails/:root/:path", :as => 'thumbnails', :endpoint => :content

      add_method :post, "/fileops/copy",           :as => "copy"
      add_method :get,  "/copy_ref/:root/:path",   :as => 'copy_ref'
      add_method :post, "/fileops/create_folder",  :as => "create_folder"
      add_method :post, "/fileops/delete",         :as => "delete"
      add_method :post, "/fileops/move",           :as => "move"

    end

  end
end

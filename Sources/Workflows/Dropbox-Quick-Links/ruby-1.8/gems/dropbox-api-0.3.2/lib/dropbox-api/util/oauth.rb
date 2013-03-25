module Dropbox
  module API

    module OAuth

      class << self

        def consumer(endpoint)
          if !Dropbox::API::Config.app_key or !Dropbox::API::Config.app_secret
            raise Dropbox::API::Error::Config.new("app_key or app_secret not provided")
          end
          ::OAuth::Consumer.new(Dropbox::API::Config.app_key, Dropbox::API::Config.app_secret,
            :site => Dropbox::API::Config.endpoints[endpoint],
            :request_token_path => Dropbox::API::Config.prefix + "/oauth/request_token",
            :authorize_path     => Dropbox::API::Config.prefix + "/oauth/authorize",
            :access_token_path  => Dropbox::API::Config.prefix + "/oauth/access_token")
        end

        def access_token(consumer, options = {})
          ::OAuth::AccessToken.new(consumer, options[:token], options[:secret])
        end

      end

    end

  end
end


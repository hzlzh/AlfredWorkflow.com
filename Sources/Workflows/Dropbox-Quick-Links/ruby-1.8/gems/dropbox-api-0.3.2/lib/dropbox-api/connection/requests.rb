module Dropbox
  module API

    class Connection

      module Requests

        def request(options = {})
          response = yield
          raise Dropbox::API::Error::ConnectionFailed if !response
          status = response.code.to_i
          case status
            when 401
              raise Dropbox::API::Error::Unauthorized
            when 403
              parsed = MultiJson.decode(response.body)
              raise Dropbox::API::Error::Forbidden.new(parsed["error"])
            when 404
              raise Dropbox::API::Error::NotFound
            when 400, 406
              parsed = MultiJson.decode(response.body)
              raise Dropbox::API::Error.new(parsed["error"])
            when 300..399
              raise Dropbox::API::Error::Redirect
            when 500..599
              raise Dropbox::API::Error
            else
              options[:raw] ? response.body : MultiJson.decode(response.body)
          end
        end



        def get_raw(endpoint, path, data = {}, headers = {})
          query = Dropbox::API::Util.query(data)
          request(:raw => true) do
            token(endpoint).get "#{Dropbox::API::Config.prefix}#{path}?#{URI.parse(URI.encode(query))}", headers
          end
        end

        def get(endpoint, path, data = {}, headers = {})
          query = Dropbox::API::Util.query(data)
          request do
            token(endpoint).get "#{Dropbox::API::Config.prefix}#{path}?#{URI.parse(URI.encode(query))}", headers
          end
        end

        def post(endpoint, path, data = {}, headers = {})
          request do
            token(endpoint).post "#{Dropbox::API::Config.prefix}#{path}", data, headers
          end
        end

        def put(endpoint, path, data = {}, headers = {})
          request do
            token(endpoint).put "#{Dropbox::API::Config.prefix}#{path}", data, headers
          end
        end

      end

    end

  end
end

module Dropbox
  module API

    class Error < Exception

      class ConnectionFailed < Exception; end
      class Config < Exception; end
      class Unauthorized < Exception; end
      class Forbidden < Exception; end
      class NotFound < Exception; end
      class Redirect < Exception; end

    end

  end
end

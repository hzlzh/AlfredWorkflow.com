module Dropbox
  module API

    module Config

      class << self
        attr_accessor :endpoints
        attr_accessor :prefix
        attr_accessor :app_key
        attr_accessor :app_secret
        attr_accessor :mode
      end

      self.endpoints = {
        :main      => "https://api.dropbox.com",
        :content   => "https://api-content.dropbox.com",
        :authorize => "https://www.dropbox.com"
      }
      self.prefix     = "/1"
      self.app_key    = nil
      self.app_secret = nil
      self.mode       = 'sandbox'

    end

  end
end

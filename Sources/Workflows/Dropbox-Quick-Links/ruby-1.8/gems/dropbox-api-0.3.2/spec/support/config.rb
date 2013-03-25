require "yaml"

config = YAML.load_file "spec/connection.yml"

Dropbox::API::Config.app_key    = config['app_key']
Dropbox::API::Config.app_secret = config['app_secret']
Dropbox::API::Config.mode       = config['mode']

Dropbox::Spec.token  = config['token']
Dropbox::Spec.secret = config['secret']

Dropbox::Spec.namespace = Time.now.to_i
Dropbox::Spec.instance  = Dropbox::API::Client.new(:token  => Dropbox::Spec.token,
                                                   :secret => Dropbox::Spec.secret)
Dropbox::Spec.test_dir = "test-#{Time.now.to_i}"

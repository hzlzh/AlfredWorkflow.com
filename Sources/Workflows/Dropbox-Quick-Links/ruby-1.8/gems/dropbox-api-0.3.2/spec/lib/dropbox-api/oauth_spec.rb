require "spec_helper"

describe Dropbox::API::OAuth do

  describe ".consumer" do

    it "raises an error if config options are not provided" do
      Dropbox::API::Config.stub!(:app_key).and_return(nil)
      lambda {
        Dropbox::API::OAuth.consumer :main
      }.should raise_error(Dropbox::API::Error::Config)
    end

  end

end


require "spec_helper"

describe Dropbox::API::Connection do

  before do
    @connection = Dropbox::API::Connection.new(:token  => Dropbox::Spec.token,
                                               :secret => Dropbox::Spec.secret)
  end

  describe "#request" do

    it "returns a parsed response when the response is a 200" do
      response = mock :code => 200, :body => '{ "a":1}'
      response = @connection.request { response }
      response.should be_an_instance_of(Hash)
    end

    it "raises a Dropbox::API::Error::Unauthorized when the response is a 401" do
      response = mock :code => 401, :body => '{ "a":1}'
      lambda do
        @connection.request { response }
      end.should raise_error(Dropbox::API::Error::Unauthorized)
    end

    it "raises a Dropbox::API::Error::Forbidden when the response is a 403" do
      response = mock :code => 403, :body => '{ "a":1}'
      lambda do
        @connection.request { response }
      end.should raise_error(Dropbox::API::Error::Forbidden)
    end

    it "raises a Dropbox::API::Error::NotFound when the response is a 404" do
      response = mock :code => 404, :body => '{ "a":1}'
      lambda do
        @connection.request { response }
      end.should raise_error(Dropbox::API::Error::NotFound)
    end

    it "raises a Dropbox::API::Error when the response is a 3xx" do
      response = mock :code => 301, :body => '{ "a":1}'
      lambda do
        @connection.request { response }
      end.should raise_error(Dropbox::API::Error::Redirect)
    end

    it "raises a Dropbox::API::Error when the response is a 5xx" do
      response = mock :code => 500, :body => '{ "a":1}'
      lambda do
        @connection.request { response }
      end.should raise_error(Dropbox::API::Error)
    end

    it "raises a Dropbox::API::Error when the response is a 400" do
      response = mock :code => 400, :body => '{ "error": "bad request" }'
      lambda do
        @connection.request { response }
      end.should raise_error(Dropbox::API::Error)
    end

    it "raises a Dropbox::API::Error when the response is a 406" do
      response = mock :code => 406, :body => '{ "error": "bad request" }'
      lambda do
        @connection.request { response }
      end.should raise_error(Dropbox::API::Error)
    end

    it "returns the raw response if :raw => true is provided" do
      response = mock :code => 200, :body => '{ "something": "more" }'
      response = @connection.request(:raw => true) { response }
      response.should == '{ "something": "more" }'
    end

  end

  describe "#consumer" do

    it "returns an appropriate consumer object" do
      @connection.consumer(:main).should be_a(::OAuth::Consumer)
    end

  end
end

require "spec_helper"
require "fileutils"

describe Dropbox::API::File do

  before do
    @io       = StringIO.new
    @client   = Dropbox::Spec.instance
    @filename = "#{Dropbox::Spec.test_dir}/spec-test-#{Time.now.to_i}.jpg"
    jpeg      = File.read("spec/fixtures/dropbox.jpg")
    @file     = @client.upload @filename, jpeg
  end

  describe "#thumbnail" do

    it "downloads a thumbnail" do
      result = @file.thumbnail

      @io << result
      @io.rewind

      jpeg = JPEG.new(@io)
      jpeg.height.should == 64
      jpeg.width.should == 64
    end

  end

end

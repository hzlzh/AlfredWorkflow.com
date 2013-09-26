
require File.dirname(__FILE__) + '/spec_helper'

describe Google::Search::Item::Video do
  describe "#initialize" do
    it "should populate attributes" do
      hash = json_fixture('video-response')['responseData']['results'].first
      item = Google::Search::Item::Video.new hash
      item.title.should include('Foo Fighters')
      item.content.should include('Foo Fighters')
      item.uri.should == 'http://www.google.com/url?q=http://www.youtube.com/watch%3Fv%3DTVboOdX9icA&source=video&vgc=rss&usg=AFQjCNFvZftyyTO-IswoCPWEmmQbskBMRA'
      item.rating.should == 4.9076071
      item.type.should == 'YouTube'
      item.published.should be_a(DateTime)
      item.thumbnail_uri.should == 'http://0.gvt0.com/vi/TVboOdX9icA/default.jpg'
      item.publisher.should == 'www.youtube.com'
      item.duration.should == 269
    end
  end
end

require File.dirname(__FILE__) + '/spec_helper'

describe Google::Search::Item::Web do
  describe "#initialize" do
    it "should populate attributes" do
      hash = json_fixture('web-response')['responseData']['results'].first
      hash['index'] = 0
      item = Google::Search::Item::Web.new hash
      item.index.should == 0
      item.title.should include('foobar - Wikipedia')
      item.content.should include('Foobar is often used')
      item.uri.should == 'http://en.wikipedia.org/wiki/Foobar'
      item.cache_uri.should == 'http://www.google.com/search?q=cache:4styY9qq7tYJ:en.wikipedia.org'
      item.visible_uri.should == 'en.wikipedia.org'
    end
  end
end
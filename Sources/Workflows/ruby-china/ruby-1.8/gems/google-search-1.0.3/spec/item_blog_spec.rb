
require File.dirname(__FILE__) + '/spec_helper'

describe Google::Search::Item::Blog do
  describe "#initialize" do
    it "should populate attributes" do
      hash = json_fixture('blog-response')['responseData']['results'].first
      item = Google::Search::Item::Blog.new hash
      item.title.should include('Foo (51)')
      item.author.should == 'KNews'
      item.uri.should == 'http://www.kaieteurnewsonline.com/2009/07/22/foo-51-amsterdam-4-12-shine-for-guyana-on-opening-day/'
      item.blog_uri.should == 'http://www.kaieteurnewsonline.com/'
      item.content.should include('Jonathon')
      item.published.should be_a(DateTime)
    end
  end
end










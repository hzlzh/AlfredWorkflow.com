
require File.dirname(__FILE__) + '/spec_helper'

describe Google::Search::Item::News do
  describe "#initialize" do
    it "should populate attributes" do
      hash = json_fixture('news-response')['responseData']['results'].first
      item = Google::Search::Item::News.new hash
      item.title.should include('TICKET TO DINING')
      item.language.should == 'en'
      item.uri.should == 'http://www.montgomerynews.com/articles/2009/07/22/entertainment/doc4a672746b0941650009917.txt'
      item.published.should be_a(DateTime)
      item.publisher.should == 'Montgomery Newspapers'
      item.content.should include('After all, it was')
      item.redirect_uri.should == 'http://news.google.com/news/url?sa=T&ct=us/0-0-0&fd=S&url=http://www.montgomerynews.com/articles/2009/07/22/entertainment/doc4a672746b0941650009917.txt&cid=0&ei=4aFnSpnxK474rQPutNHRAQ&usg=AFQjCNGsuTniL5DY24lNJ8qy204ZWjQoKA'
      item.location.should == 'Fort Washington,PA,USA'
    end
  end
end
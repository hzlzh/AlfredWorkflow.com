
require File.dirname(__FILE__) + '/spec_helper'

describe Google::Search::News do
  before :each do
    @search = Google::Search::News.new :query => 'foo'  
  end
  
  describe "#get_uri" do
    describe "relative_to" do
      it "should set relative to geo" do
        @search.relative_to = 'Edmonton Alberta'
        @search.get_uri.should_not include('geo=Edmonton%20Alberta')
      end
    end
    
    describe "topic" do
      it "should validate" do
        @search.topic = :world
        @search.get_uri.should include('topic=world')
        @search.topic = :foo
        lambda { @search.get_uri }.should raise_error(Google::Search::Error, /topic/)
      end
    end
    
    describe "edition" do
      it "should set edition" do
        @search.edition = :en
        @search.get_uri.should include('ned=en')
      end
    end
  end
end
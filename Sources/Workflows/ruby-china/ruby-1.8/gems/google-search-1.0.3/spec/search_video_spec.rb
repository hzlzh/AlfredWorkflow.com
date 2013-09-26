
require File.dirname(__FILE__) + '/spec_helper'

describe Google::Search::Video do
  before :each do
    @search = Google::Search::Video.new :query => 'foo'  
  end
  
  describe "#get_uri" do
    describe "order_by" do
      it "should validate" do
        @search.order_by = :date
        lambda { @search.get_uri }.should_not raise_error
      end
      
      it "should raise an error when invalid" do
        @search.order_by = :foo
        lambda { @search.get_uri }.should raise_error(Google::Search::Error, /order/)
      end
    end
    
    describe "filter" do
      it "should default to 1" do
        @search.get_uri.should include('filter=1')
      end
      
      it "should consider anything positive as 1" do
        @search.filter = true
        @search.get_uri.should include('filter=1')
        @search.filter = 123
        @search.get_uri.should include('filter=1')
      end
      
      it "should consider anything negative as 0" do
        @search.filter = false
        @search.get_uri.should include('filter=0')
        @search.filter = nil
        @search.get_uri.should include('filter=0')
      end
    end
  end
end
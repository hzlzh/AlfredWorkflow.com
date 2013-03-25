
require File.dirname(__FILE__) + '/spec_helper'

describe Google::Search::Patent do
  before :each do
    @search = Google::Search::Patent.new :query => 'foo'  
  end
  
  describe "#get_uri" do
    describe "issued_only" do
      it "should return issued and filed by default" do
        @search.get_uri.should_not include('as_psrg')
        @search.get_uri.should_not include('as_psra')
      end
      
      it "should return issued when true" do
        @search.issued_only = true
        @search.get_uri.should include('as_psrg=1')
      end
      
      it "should return filed when false" do
        @search.issued_only = false
        @search.get_uri.should include('as_psra=1')
      end
    end
  end
end
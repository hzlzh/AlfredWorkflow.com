
require File.dirname(__FILE__) + '/spec_helper'

describe Google::Search::Response do
  before :each do
    @response = Google::Search::Response.new json_fixture('web-response')
  end
  
  describe "#initialize" do
    it "should not throw an error when invalid" do
      lambda { Google::Search::Response.new json_fixture('invalid-response') }.should_not raise_error
    end
    
    it "should set #items" do
      @response.items.first.should be_a(Google::Search::Item)
      @response.items.length.should == 4
    end
    
    it "should set item indices" do
      @response.items[0].index.should == 0
      @response.items[1].index.should == 1
      @response.items[2].index.should == 2
    end
    
    it "should set item indices when page is present" do
      @response = Google::Search::Response.new json_fixture('web-2-response')
      @response.size.should == :small
      @response.page.should == 1
      @response.items[0].index.should == 4
      @response.items[1].index.should == 5
      @response.items[2].index.should == 6
    end
    
    it "should set #estimated_count" do
      @response.estimated_count.should == 33400000
    end
    
    it "should set #page" do
      @response.page.should == 0
    end
    
    it "should set #status" do
      @response.status.should == 200
    end
    
    it "should set #details" do
      @response.details.should be_nil
    end
  end
    
  describe "#valid?" do
    it "should return false when response status is not 200" do
      response = Google::Search::Response.new 'responseStatus' => 400
      response.should_not be_valid
    end
    
    it "should return true when status is 200" do
      response = Google::Search::Response.new 'responseStatus' => 200, 'responseData' => { 'results' => [] }
      response.should be_valid
    end
  end
  
end
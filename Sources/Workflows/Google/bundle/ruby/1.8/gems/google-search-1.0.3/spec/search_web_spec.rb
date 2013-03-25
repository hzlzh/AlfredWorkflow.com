# -*- coding: utf-8 -*-

require File.dirname(__FILE__) + '/spec_helper'

describe Google::Search::Web do
  before :each do
    @search = Google::Search::Web.new :query => 'foo'  
  end
  
  describe "#get_uri" do
    describe "safety_level" do
      it "should validate" do
        @search.safety_level = :moderate
        lambda { @search.get_uri }.should_not raise_error
      end
      
      it "should raise an error when invalid" do
        @search.safety_level = :foo
        lambda { @search.get_uri }.should raise_error(Google::Search::Error, /safety/)
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
    describe "multibyte string query" do
      it "url encoding" do
        @search.query = "日本語"
        @search.get_uri.should include('%E6%97%A5%E6%9C%AC%E8%AA%9E')
      end
    end
  end
end

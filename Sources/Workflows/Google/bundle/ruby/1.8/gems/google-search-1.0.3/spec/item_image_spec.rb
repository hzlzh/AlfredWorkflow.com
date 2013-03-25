
require File.dirname(__FILE__) + '/spec_helper'

describe Google::Search::Item::Image do
  describe "#initialize" do
    it "should populate attributes" do
      hash = json_fixture('image-response')['responseData']['results'].first
      item = Google::Search::Item::Image.new hash
      item.id.should == 'IYlLzX-w4vX2AM'
      item.title.should == 'foo_fighters.jpg'
      item.uri.should == 'http://tomdiaz.files.wordpress.com/2009/06/foo_fighters.jpg'
      item.content.should include('Not FBI Agents')
      item.context_uri.should == 'http://tomdiaz.wordpress.com/2009/06/'
      item.width.should == 883
      item.height.should == 891
      item.thumbnail_uri.should == 'http://images.google.com/images?q=tbn:IYlLzX-w4vX2AM:tomdiaz.files.wordpress.com/2009/06/foo_fighters.jpg'
      item.thumbnail_width.should == 145
      item.thumbnail_height.should == 146
    end
  end
end

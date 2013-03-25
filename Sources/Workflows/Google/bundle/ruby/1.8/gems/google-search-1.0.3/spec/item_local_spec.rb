
require File.dirname(__FILE__) + '/spec_helper'

describe Google::Search::Item::Local do
  describe "#initialize" do
    it "should populate attributes" do
      hash = json_fixture('local-response')['responseData']['results'].first
      item = Google::Search::Item::Local.new hash
      item.city.should == 'San Francisco'
      item.type.should == 'local'
      item.region.should == 'CA'
      item.uri.should == 'http://www.google.com/local?source=uds&q=foo&sll=37.795279%2C-122.407451&latlng=37795279%2C-122407451%2C1909516875098392575&near=37.795279%2C-122.407451'
      item.directions_from_here_uri.should == 'http://www.google.com/maps?source=uds&saddr=852+Washington+St%2C+San+Francisco%2C+CA+%28Foo+Wah+Cheung%29+%4037.795279%2C-122.407451&iwstate1=dir%3Afrom'
      item.directions_to_here_uri.should == 'http://www.google.com/maps?source=uds&daddr=852+Washington+St%2C+San+Francisco%2C+CA+%28Foo+Wah+Cheung%29+%4037.795279%2C-122.407451&iwstate1=dir%3Ato'
      item.directions_uri.should == 'http://www.google.com/maps?source=uds&daddr=852+Washington+St%2C+San+Francisco%2C+CA+%28Foo+Wah+Cheung%29+%4037.795279%2C-122.407451&saddr'
      item.title.should == 'Foo Wah Cheung'
      item.accuracy.should == 8
      item.country.should == 'United States'
      item.max_age.should == 604800
      item.thumbnail_uri.should == 'http://mt.google.com/mapdata?cc=us&tstyp=5&Point=b&Point.latitude_e6=37795279&Point.longitude_e6=-122407451&Point.iconid=15&Point=e&w=150&h=100&zl=4'
      item.long.should == -122.407451
      item.street_address.should == '852 Washington St'
      item.content.should == ''
      item.lat.should == 37.795279
      item.viewport_mode.should == 'computed'
      item.phone_numbers.should == ['(415) 391-4067']
      item.address_lines.should == ['852 Washington St', 'San Francisco, CA']
     end
  end
end
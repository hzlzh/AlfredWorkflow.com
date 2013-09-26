
require File.dirname(__FILE__) + '/spec_helper'

describe Google::Search::Item::Patent do
  describe "#initialize" do
    it "should populate attributes" do
      hash = json_fixture('patent-response')['responseData']['results'].first
      item = Google::Search::Item::Patent.new hash
      item.title.should == 'SZE-FOO CHIEN'
      item.id.should == 3468158
      item.content.should include('METHOD OF AND APPARATUS FOR DETERMINING RH')
      item.assignee.should == ''
      item.application_date.should be_a(DateTime)
      item.uri.should == 'http://www.google.com/patents/about?id=GDMdAAAAEBAJ&dq=foo&client=internal-uds&source=uds'
      item.thumbnail_uri.should == 'http://bks9.books.google.com/patents?id=GDMdAAAAEBAJ&printsec=drawing&img=1&zoom=1&sig=ACfU3U10b3w-4hMfKTEykPmtqnoObaLhaA'
      item.status.should == 'issued'
    end
  end
end
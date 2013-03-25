
require File.dirname(__FILE__) + '/spec_helper'

describe Google::Search::Item::Book do
  describe "#initialize" do
    it "should populate attributes" do
      hash = json_fixture('book-response')['responseData']['results'].first
      item = Google::Search::Item::Book.new hash
      item.title.should include('Foo Fighters')
      item.author.should == '<b>Foo</b> Fighters (CRT), Hal Leonard Publishing Corporation'
      item.id.should == 'ISBN1423404580'
      item.uri.should == 'http://books.google.com/books?id=vUoCAgAACAAJ&dq=foo&client=internal-uds&source=uds'
      item.thumbnail_uri.should == 'http://bks6.books.google.com/books?id=vUoCAgAACAAJ&printsec=frontcover&img=1&zoom=5&sig=ACfU3U1NHHhXuERH30Xfn0GC3A0BW5nMPg'
      item.published_year.should == 2006
      item.pages.should == 69
    end
  end
end
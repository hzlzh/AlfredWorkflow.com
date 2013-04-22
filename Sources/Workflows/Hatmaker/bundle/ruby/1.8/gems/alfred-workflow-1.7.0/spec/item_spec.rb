require "spec_helper"

describe "Feedback Item" do
  it "should return raise ArgumentError without Item title" do
    expect { Alfred::Feedback::Item.new }.to raise_error(ArgumentError)
  end

  it "should match default xml item tags" do
    item = Alfred::Feedback::Item.new("title")
    item.title.should eql "title"
    item.subtitle.should eql nil
    item.autocomplete.should eql nil
    item.arg.should eql item.title
    item.valid.should eql "yes"
    item.type.should eql "default"

    default_icon = {:type => "default", :name => "icon.png"}
    item.icon.should eql default_icon
  end

end

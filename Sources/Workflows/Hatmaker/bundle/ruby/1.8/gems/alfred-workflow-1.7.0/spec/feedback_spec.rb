require "spec_helper"

describe "Feedback" do

  before :all do
    @feedback = Alfred::Feedback.new

    @item_elements = %w{title subtitle icon}
    @item_attributes = %w{uid arg autocomplete}
  end

  it "should create a basic XML response" do
    @feedback.add_item(:uid          => "uid"          ,
                       :arg          => "arg"          ,
                       :autocomplete => "autocomplete" ,
                       :title        => "Title"        ,
                       :subtitle     => "Subtitle")

    xml_data = <<-END.strip_heredoc
      <?xml version="1.0"?>
      <items>
        <item valid="yes" arg="arg" autocomplete="autocomplete" uid="uid">
          <title>Title</title>
          <subtitle>Subtitle</subtitle>
          <icon>icon.png</icon>
        </item>
      </items>
    END

    compare_xml(xml_data, @feedback.to_xml).should == true
  end

end

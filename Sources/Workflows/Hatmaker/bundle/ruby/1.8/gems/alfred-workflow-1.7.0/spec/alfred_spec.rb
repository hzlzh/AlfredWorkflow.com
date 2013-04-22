require "spec_helper"

describe "Alfred" do

  before :all do
    @alfred =  Alfred::Core.new
    Dir.chdir("test/workflow/")
  end

  it "should return a valid bundle id" do
    @alfred.bundle_id.should == "me.zhaowu.alfred-workflow-gem"
  end

  context "Setting" do

    it "should use yaml as defualt backend" do
      @setting = @alfred.setting
      @setting.format.should == "yaml"
    end

    context "with Yaml Backend" do
      before :all do
        @setting = @alfred.setting do
          use_setting_file :format => 'yaml'
        end
      end
      it "should correctly load settings" do
        settings = @setting.load
        settings[:id].should == "me.zhaowu.alfred-workflow-gem"
      end

      it "should correctly save settings" do
        settings = @setting.load
        settings[:language] = "Chinese"
        @setting.dump(settings, :flush => true)

        settings = @alfred.setting.load
        settings[:language].should == "Chinese"
      end

      after :all do
        File.unlink(@setting.setting_file)
      end
    end

    context "with Plist Backend" do
      before :all do
        @setting = @alfred.setting do
          use_setting_file :format => 'plist'
        end
      end

      it "should correctly load settings" do
        settings = @setting.load
        settings[:id].should == "me.zhaowu.alfred-workflow-gem"
      end

      it "should correctly save settings" do
        settings = @setting.load
        settings[:language] = "Chinese"
        @setting.dump(settings, :flush => true)

        settings = @alfred.setting.load
        settings[:language].should == "Chinese"
      end

      after :all do
        File.unlink(@setting.setting_file)
      end
    end

  end


  context "Cached Feedback" do
    it "should have correct default cache file" do
      @alfred.with_cached_feedback do
        use_cache_file :expire => 10
      end
      fb = @alfred.feedback
      fb.cache_file.should == File.join(@alfred.volatile_storage_path, "cached_feedback")
    end

    it "should set correct cache file" do
      @alfred.with_cached_feedback do
        use_cache_file :file => "cached_feedback"
      end
      fb = @alfred.feedback
      fb.cache_file.should == "cached_feedback"
    end

    context "With Valid Cached File" do
      before :all do
        @alfred.with_cached_feedback do
          use_cache_file
        end

        fb = @alfred.feedback

        fb.add_item(:uid          => "uid"          ,
                    :arg          => "arg"          ,
                    :autocomplete => "autocomplete" ,
                    :title        => "Title"        ,
                    :subtitle     => "Subtitle")

        @xml_data = <<-END.strip_heredoc
        <?xml version="1.0"?>
        <items>
          <item valid="yes" arg="arg" autocomplete="autocomplete" uid="uid">
            <title>Title</title>
            <subtitle>Subtitle</subtitle>
            <icon>icon.png</icon>
          </item>
        </items>
        END
        fb.put_cached_feedback
      end


      it "should correctly load cached feedback" do
        alfred =  Alfred::Core.new
        alfred.with_cached_feedback do
          use_cache_file
        end

        fb = alfred.feedback

        compare_xml(@xml_data, fb.get_cached_feedback.to_xml).should == true
      end

      it "should expire as defined" do
        alfred =  Alfred::Core.new
        alfred.with_cached_feedback do
          use_cache_file :expire => 1
        end
        sleep 1
        fb = alfred.feedback
        fb.get_cached_feedback.should == nil

      end

    end


    after :all do
      @alfred.with_cached_feedback
      fb = @alfred.feedback
      File.unlink(fb.cache_file)
    end

  end

end




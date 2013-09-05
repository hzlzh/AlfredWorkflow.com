require "spec_helper"

describe "Setting" do
  before :all do
    setup_workflow
    @alfred =  Alfred::Core.new
  end

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

  after :all do
    reset_workflow
  end

end






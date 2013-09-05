require "spec_helper"

describe "UI" do

  before :all do
    setup_workflow
    @alfred = Alfred::Core.new do |a|
      @ui = Alfred::LogUI.new(bundle_id)
    end
  end

  it "should use bundle id as log progname " do
    @alfred.ui.progname.should == @alfred.bundle_id
  end

  after :all do
    reset_workflow
    File.unlink(@alfred.ui.log_file)
  end

end

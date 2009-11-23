require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Application" do
  describe "route recognition" do
    it "generates params for \"/\" (#root)" do
      params_from(:get, "/").should == {:controller => "projects", :action => "index"}
    end

    it "generates params for #message" do
      params_from(:get, "/message").should == {:controller => 'message', :action => 'index'}
    end
  end

  describe "route generation" do
    it "maps #message" do
      route_for(:controller => 'message', :action => 'index').should == {:path =>"/message", :method => :get}
    end
  end

  describe 'named paths' do
    it 'generates message_path'do
      message_path.should eql('/message')
    end
  end
end

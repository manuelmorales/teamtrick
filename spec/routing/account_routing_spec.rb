require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Account" do
  describe "route recognition" do
    it "generates params for #login" do
      params_from(:get, "/login").should == {:controller => 'account', :action => 'login'}
    end

    it "generates params for #logout" do
      params_from(:get, "/logout").should == {:controller => 'account', :action => 'logout'}
    end
  end

  describe "route generation" do
    it "maps #login" do
      route_for(:controller => 'account', :action => 'login').should == {:path =>"/login", :method => :get}
    end

    it "maps #logout" do
      route_for(:controller => 'account', :action => 'logout').should == {:path =>"/logout", :method => :get}
    end
  end

  describe 'named paths' do
    it 'generates login'do
      login_path.should eql('/login')
    end

    it 'generates logout'do
      logout_path.should eql('/logout')
    end
  end
end

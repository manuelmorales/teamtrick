require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe UsersController do
  describe "route generation" do
    it "maps #index" do
      route_for(:controller => "users", :action => "index").should == "/users"
    end
  
    it "maps #new" do
      route_for(:controller => "users", :action => "new").should == "/users/new"
    end
  
    it "maps #show" do
      route_for(:controller => "users", :action => "show", :id => "1").should == "/users/1"
    end
  
    it "maps #edit" do
      route_for(:controller => "users", :action => "edit", :id => "1").should == "/users/1/edit"
    end

    it "maps #create" do
      route_for(:controller => "users", :action => "create").should == {:path => "/users", :method => :post}
    end

    it "maps #update" do
      route_for(:controller => "users", :action => "update", :id => "1").should == {:path =>"/users/1", :method => :put}
    end

    it "maps #destroy" do
      route_for(:controller => "users", :action => "destroy", :id => "1").should == {:path =>"/users/1", :method => :delete}
    end

    it "maps #my_profile" do
      route_for(:controller => "users", :action => "my_profile").should == {:path =>"/my_profile"}
    end
  end

  describe "route recognition" do
    it "generates params for #index" do
      params_from(:get, "/users").should == {:controller => "users", :action => "index"}
    end
  
    it "generates params for #new" do
      params_from(:get, "/users/new").should == {:controller => "users", :action => "new"}
    end
  
    it "generates params for #create" do
      params_from(:post, "/users").should == {:controller => "users", :action => "create"}
    end
  
    it "generates params for #show" do
      params_from(:get, "/users/1").should == {:controller => "users", :action => "show", :id => "1"}
    end
  
    it "generates params for #edit" do
      params_from(:get, "/users/1/edit").should == {:controller => "users", :action => "edit", :id => "1"}
    end
  
    it "generates params for #update" do
      params_from(:put, "/users/1").should == {:controller => "users", :action => "update", :id => "1"}
    end
  
    it "generates params for #destroy" do
      params_from(:delete, "/users/1").should == {:controller => "users", :action => "destroy", :id => "1"}
    end

    it "generates params for #my_profile" do
      params_from(:get, "/my_profile").should == {:controller => "users", :action => "my_profile"}
    end

  end
end

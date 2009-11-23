require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe DutiesController do
  describe "route_for route generation" do
    it "maps #index" do
      route_for(:controller => "duties", :action => "index", :project_id => "2").should == "/projects/2/duties"
    end

    it "maps #new" do
      route_for(:controller => "duties", :action => "new", :project_id => "2").should == "/projects/2/duties/new"
    end

    it "maps #show" do
      route_for(:controller => "duties", :action => "show", :id => "1", :project_id => "2").should == "/projects/2/duties/1"
    end

    it "maps #edit" do
      route_for(:controller => "duties", :action => "edit", :id => "1", :project_id => "2").should == "/projects/2/duties/1/edit"
    end

    it "maps #create" do
      route_for(:controller => "duties", :action => "create", :project_id => "2").should == {:path => "/projects/2/duties", :method => :post}
    end

    it "maps #update" do
      route_for(:controller => "duties", :action => "update", :id => "1", :project_id => "2").should == {:path =>"/projects/2/duties/1", :method => :put}
    end

    it "maps #destroy" do
      route_for(:controller => "duties", :action => "destroy", :id => "1", :project_id => "2").should == {:path =>"/projects/2/duties/1", :method => :delete}
    end
  end

  describe "*_path route generation" do
    it_should_map_path "project_duties_path(2)", "/projects/2/duties"
    it_should_map_path "new_project_duty_path(2)", "/projects/2/duties/new"
    it_should_map_path "project_duty_path(2,1)", "/projects/2/duties/1"
    it_should_map_path "edit_project_duty_path(2,1)", "/projects/2/duties/1/edit"
  end

  describe "route recognition" do
    it "generates params for #index" do
      params_from(:get, "/projects/2/duties").should == {:controller => "duties", :action => "index", :project_id => "2"}
    end

    it "generates params for #new" do
      params_from(:get, "/projects/2/duties/new").should == {:controller => "duties", :action => "new", :project_id => "2"}
    end

    it "generates params for #create" do
      params_from(:post, "/projects/2/duties").should == {:controller => "duties", :action => "create", :project_id => "2"}
    end

    it "generates params for #show" do
      params_from(:get, "/projects/2/duties/1").should == {:controller => "duties", :action => "show", :id => "1", :project_id => "2"}
    end

    it "generates params for #edit" do
      params_from(:get, "/projects/2/duties/1/edit").should == {:controller => "duties", :action => "edit", :id => "1", :project_id => "2"}
    end

    it "generates params for #update" do
      params_from(:put, "/projects/2/duties/1").should == {:controller => "duties", :action => "update", :id => "1", :project_id => "2"}
    end

    it "generates params for #destroy" do
      params_from(:delete, "/projects/2/duties/1").should == {:controller => "duties", :action => "destroy", :id => "1", :project_id => "2"}
    end
  end
end

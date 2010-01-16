require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SprintsController do
  describe "route_for route generation" do
    it "maps #index" do
      route_for(:controller => "sprints", :action => "index", :project_id => "2").should == "/projects/2/sprints"
    end

    it "maps #new" do
      route_for(:controller => "sprints", :action => "new", :project_id => "2").should == "/projects/2/sprints/new"
    end

    it "maps #show" do
      route_for(:controller => "sprints", :action => "show", :id => "1", :project_id => "2").should == "/projects/2/sprints/1"
    end

    it "maps #show with mode = planning" do
      route_for(:controller => "sprints", :action => "show_planning", :id => "1", :project_id => "2", :mode => "planning").should == "/projects/2/sprints/1/planning"
    end

    it "maps #show with mode = current" do
      route_for(:controller => "sprints", :action => "show_current", :id => "1", :project_id => "2", :mode => "current").should == "/projects/2/sprints/1/current"
    end

    it "maps #edit with mode = planning" do
      route_for(:controller => "sprints", :action => "edit", :id => "1", :project_id => "2", :mode => "planning").should == "/projects/2/sprints/1/planning/edit"
    end

    it "maps #create" do
      route_for(:controller => "sprints", :action => "create", :project_id => "2").should == {:path => "/projects/2/sprints", :method => :post}
    end

    it "maps #update" do
      route_for(:controller => "sprints", :action => "update", :id => "1", :project_id => "2").should == {:path =>"/projects/2/sprints/1", :method => :put}
    end

    it "maps #update with mode = planning" do
      route_for(:controller => "sprints", :action => "update", :id => "1", :project_id => "2", :mode => "planning").should == {:path =>"/projects/2/sprints/1/planning", :method => :put}
    end

    it "maps #destroy" do
      route_for(:controller => "sprints", :action => "destroy", :id => "1", :project_id => "2").should == {:path =>"/projects/2/sprints/1", :method => :delete}
    end

    it "maps #finish_planning" do
      route_for(:controller => "sprints", :action => "finish_planning", :id => "1", :project_id => "2").should == {:path =>"/projects/2/sprints/1/finish_planning", :method => :post}
    end

    it "maps #day" do
      route_for(:controller => "sprints", :action => "day", :sprint_id => "1", :project_id => "2", :day => "3").should == 
        {:path => "projects/2/sprints/1/day/3"}
    end

    it "maps #day with :day => nil" do
      route_for(:controller => "sprints", :action => "day", :sprint_id => "1", :project_id => "2").should == 
        {:path => "projects/2/sprints/1/day"}
    end
  end

  describe "*_path route generation" do
    it_should_map_path "project_sprints_path(2)", "/projects/2/sprints"
    it_should_map_path "new_project_sprint_path(2)", "/projects/2/sprints/new"
    it_should_map_path "project_sprint_path(2,1)", "/projects/2/sprints/1"
    it_should_map_path 'project_sprint_planning_path(2,1)', "/projects/2/sprints/1/planning"
    it_should_map_path 'project_sprint_current_path(2,1)', "/projects/2/sprints/1/current"
    it_should_map_path 'finish_planning_project_sprint_path(2,1)', "/projects/2/sprints/1/finish_planning"
    it_should_map_path 'edit_project_sprint_planning_path(2,1)', "/projects/2/sprints/1/planning/edit"
    it_should_map_path 'project_sprint_day_path(2,1,3)', "/projects/2/sprints/1/day/3"
    it_should_map_path 'project_sprint_empty_day_path(2,1)', "/projects/2/sprints/1/day"
  end

  describe "route recognition" do
    it "generates params for #index" do
      params_from(:get, "/projects/2/sprints").should == {:controller => "sprints", :action => "index", :project_id => "2"}
    end

    it "generates params for #new" do
      params_from(:get, "/projects/2/sprints/new").should == {:controller => "sprints", :action => "new", :project_id => "2"}
    end

    it "generates params for #create" do
      params_from(:post, "/projects/2/sprints").should == {:controller => "sprints", :action => "create", :project_id => "2"}
    end

    it "generates params for #show" do
      params_from(:get, "/projects/2/sprints/1").should == {:controller => "sprints", :action => "show", :id => "1", :project_id => "2"}
    end

    it "generates params for #show with mode = planning" do
      params_from(:get, "/projects/2/sprints/1/planning").should == {:controller => "sprints", :action => "show_planning", :id => "1", :project_id => "2", :mode => "planning"}
    end

    it "generates params for #show with mode = current" do
      params_from(:get, "/projects/2/sprints/1/current").should == {:controller => "sprints", :action => "show_current", :id => "1", :project_id => "2", :mode => "current"}
    end

    it "generates params for #edit" do
      params_from(:get, "/projects/2/sprints/1/edit").should == {:controller => "sprints", :action => "edit", :id => "1", :project_id => "2"}
    end

    it "generates params for #edit with mode = planning" do
      params_from(:get, "/projects/2/sprints/1/planning/edit").should == {:controller => "sprints", :action => "edit", :id => "1", :project_id => "2", :mode => "planning"}
    end

    it "generates params for #update" do
      params_from(:put, "/projects/2/sprints/1").should == {:controller => "sprints", :action => "update", :id => "1", :project_id => "2"}
    end

    it "generates params for #update with mode = planning" do
      params_from(:put, "/projects/2/sprints/1/planning").should == {:controller => "sprints", :action => "update", :id => "1", :project_id => "2", :mode => "planning"}
    end

    it "generates params for #destroy" do
      params_from(:delete, "/projects/2/sprints/1").should == {:controller => "sprints", :action => "destroy", :id => "1", :project_id => "2"}
    end

    it "generates params for #finish_planning" do
      params_from(:post, "/projects/2/sprints/1/finish_planning").should == {:controller => "sprints", :action => "finish_planning", :id => "1", :project_id => "2"}
    end

    it "generates params for #day" do
      params_from(:get, "/projects/2/sprints/1/day/3").should == 
        {:controller => "sprints", :action => "day", :sprint_id => "1", :project_id => "2", :day => "3"}
    end
  end
end

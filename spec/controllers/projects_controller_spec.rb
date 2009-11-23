require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ProjectsController do
  fixtures :roles, :projects, :users, :duties

  def mock_project(stubs={})
    @mock_project ||= mock_model(Project, stubs)
  end


  before :each do
    login_as users(:admin)
  end

  describe "responding to GET index" do
    def do_request
      get :index
    end

    it_should_require_login

    it "should expose all projects as @records" do
      do_request
      assigns[:records].should be_full_of(:projects)
    end

    it "as an admin should show all projects" do
      login_as users(:admin)
      do_request
      assigns[:records].should have(2).things
    end

    it "as a non-admin user should show only those projects where current_user plays a Role" do
      users(:any).duties.each(&:destroy)
      login_as users(:any)
      do_request
      assigns[:records].should be_empty
    end
  end

  describe "responding to GET show" do
    def do_request
      get :show, :id => projects(:project_0).id
    end

    it_should_require_login

    it "should success if User plays a Role in that Project" do
      project = projects(:project_0)
      user = users(:any)

      login_as user
      get :show, :id => project.id

      response.should be_success
    end

    it "should redirect to error message if User do not plays a Role in that Project" do
      project = projects(:project_0)
      user = users(:any)
      user.duties.each(&:destroy)

      login_as user
      get :show, :id => project.id

      response.should redirect_to message_path
    end

    it "should success when User is admin even if User do not plays a Role in that Project" do
      users(:admin).duties.each(&:destroy)
      get :show, :id => projects(:project_0).id

      response.should be_success
    end

    it "should expose the requested project as @record" do
      do_request
      assigns[:record].should == projects(:project_0)
    end
  end

  describe "responding to GET new" do
    def do_request
      get :new
    end

    it_should_require_login
    it_should_require_admin

    it "should expose a new project as @record" do
      do_request
      assigns[:record].should be_new_record
    end
  end

  describe "responding to GET edit" do
    def do_request
      get :edit, :id => projects(:project_0).id
    end

    it_should_require_login
    it_should_require_admin

    it "should expose the requested project as @record" do
      do_request
      assigns[:record].should == projects(:project_0)
    end
  end

  describe "responding to POST create" do
    def do_request
      post :create, :record => project_required_values
    end

    it_should_require_login
    it_should_require_admin

    describe "with valid params" do
      it "should expose a newly created project as @record" do
        do_request
        assigns(:record).should_not be_new_record
        assigns(:record).name.should == project_required_values[:name]
      end

      it "should redirect to the projects list" do
        do_request
        response.should redirect_to(projects_path)
      end
    end
    
    describe "with invalid params" do
      def do_request
        post :create, :record => {:name => nil}
      end

      it "should expose a newly created but unsaved project as @record" do
        do_request
        assigns(:record).should be_new_record
      end

      it "should re-render the 'create' template" do
        do_request
        response.should render_template('create')
      end
    end
  end

  describe "responding to PUT update" do
    fixtures :projects

    def do_request
      @id = projects(:project_0).id
      @name = "New Name"
      put :update, :id => @id, :record => {:name => @name}
    end

    it_should_require_login
    it_should_require_admin

    describe "with valid params" do
      it "should update the requested project" do
        do_request
        Project.find(@id).name.should == @name
      end

      it "should expose the requested project as @record" do
        do_request
        assigns(:record).should == Project.find(@id)
      end

      it "should redirect to the projects list" do
        do_request
        response.should redirect_to(projects_path)
      end
    end
    
    describe "with invalid params" do
      def do_request
        @id = projects(:project_0).id
        @name = nil
        put :update, :id => @id, :record => {:name => @name}
      end

      it "should expose the requested project as @record" do
        do_request
        assigns(:record).should == Project.find(@id)
      end

      it "should re-render the 'update' template" do
        do_request
        response.should render_template('update')
      end
    end
  end

  describe "responding to DELETE destroy" do
    fixtures :projects

    def do_request
      @id = projects(:project_0).id
      delete :destroy, :id => @id
    end

    it_should_require_login
    it_should_require_admin

    it "should destroy the requested project" do
      do_request
      Project.find_by_id(@id).should == nil
    end
  
    it "should redirect to the projects list" do
      do_request
      response.should redirect_to(projects_path)
    end
  end
end

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe TasksController do
  fixtures :roles, :tasks, :stories, :users, :duties, :projects

  def mock_task(stubs={})
    @mock_task ||= mock_model(Task, :story => mock_story)
  end

  def mock_story(stubs={})
    @mock_sprint ||= mock_model(Story, stubs)
  end

  before :each do
    login_as users(:admin)
    @current_project = mock_current_project
    @default_task = tasks(:task_p0_s0_0)
    @default_story = stories(:story_p0_0)
  end

  describe "responding to GET index" do
    def do_request
      get :index
    end

    it_should_require_login

    it "should expose all tasks as @records" do
      do_request
      assigns[:records].should be_full_of(:tasks)
    end
  end

  describe "responding to GET show" do
    def do_request
      get :show, :id => @default_task.id
    end

    it_should_require_login
    it_should_block_users_without_duty_for_current_project
    it_should_success_for_admins_without_duty
    it_should_success_for_users_with_role :team_member
    it_should_success_for_users_with_role :scrum_master
    it_should_success_for_users_with_role :product_owner

    it "should expose current task as @record" do
      do_request
      assigns[:record].should == @default_task
    end
  end

  describe "responding to GET new" do
    def do_request
      get :new
    end

    it_should_require_login
    it_should_success_for_admins_without_duty
    it_should_success_for_users_with_role :scrum_master
    it_should_success_for_users_with_role :product_owner
    it_should_success_for_users_with_role :team_member
    it_should_block_users_without_duty_for_current_project

    it "should expose the new record as @record" do
      do_request
      assigns[:record].should be_new_record
    end
  end

  describe "responding to GET edit" do
    before :each do
      Task.stub!(:find).with("37").and_return(@default_task)
    end

    def do_request
      get :edit, :id => "37"
    end

    it_should_require_login
    it_should_success_for_admins_without_duty
    it_should_success_for_users_with_role :scrum_master
    it_should_success_for_users_with_role :product_owner
    it_should_success_for_users_with_role :team_member
    it_should_block_users_without_duty_for_current_project

    it "should expose the requested Task as @record" do
      do_request
      assigns[:record].should == @default_task
    end
  end

  describe "responding to POST create" do
    def do_request
      post :create, :record => task_required_values.merge(:story => @default_story.id.to_s)
    end

    it_should_require_login
    it_should_success_for_admins_without_duty
    it_should_success_for_users_with_role :scrum_master
    it_should_success_for_users_with_role :product_owner
    it_should_success_for_users_with_role :team_member
    it_should_block_users_without_duty_for_current_project

    it "should increase the number of Tasks" do
      lambda{ do_request }.should change{ Task.count }.by(1)
    end
    
    describe "with invalid params" do
      def do_request
        post :create, :record => {:user => nil}
      end

      it "should expose a newly created but unsaved record as @record" do
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
    def do_request
      @id = @default_task.id
      @original_estimation = 33
      put :update, :id => @id, :record => {:original_estimation => @original_estimation}
    end

    it_should_require_login
    it_should_success_for_admins_without_duty
    it_should_success_for_users_with_role :scrum_master
    it_should_success_for_users_with_role :product_owner
    it_should_success_for_users_with_role :team_member
    it_should_block_users_without_duty_for_current_project

    describe "with valid params" do
      it "should update the requested record" do
        do_request
        Task.find(@id).original_estimation.should == @original_estimation
      end

      it "should redirect to index" do
        do_request
        response_should_be_right
      end
    end
    
    describe "with invalid params" do
      def do_request
        @id = @default_task.id
        @original_estimation = nil
        put :update, :id => @id, :record => {:original_estimation => @original_estimation}
      end

      it "should expose the requested record as @record" do
        do_request
        assigns(:record).should == @default_task
      end

      it "should re-render the 'update' template" do
        do_request
        response.should render_template('update')
      end
    end
  end

  describe "responding to DELETE destroy" do
    def do_request
      delete :destroy, :id => @default_task.id 
    end

    it_should_require_login
    it_should_success_for_admins_without_duty
    it_should_success_for_users_with_role :scrum_master
    it_should_success_for_users_with_role :product_owner
    it_should_success_for_users_with_role :team_member
    it_should_block_users_without_duty_for_current_project

    it "should destroy the requested record" do
      lambda{ do_request }.should change{ Task.count }.by(-1)
    end
  end
end

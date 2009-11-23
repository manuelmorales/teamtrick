require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PlanningsController do
  fixtures :roles, :plannings, :stories, :tasks, :sprints, :users, :projects

  before :each do
    login_as users(:admin)
    @current_project = mock_current_project
    @default_planning = plannings(:planning_p0_s0)
    @default_story = @default_planning.story
    @default_sprint = @default_planning.sprint
    @default_user = users(:any)
  end

  describe "responding to GET index" do
    def do_request
      get :index
    end

    it_should_require_login

    it "should expose all plannings as @records" do
      do_request
      assigns[:records].should be_full_of(:plannings)
    end
  end

  describe "responding to GET show" do
    def do_request
      get :show, :id => @default_planning.id
    end

    it_should_require_login
    it_should_block_users_without_duty_for_current_project

    it "should not block admins anyway" do
      user = users(:admin)
      user.duties.destroy_all
      login_as user
      do_request
      response.should be_success
    end

    it "should success for a normal user" do
      login_as users(:any)
      do_request
      response.should be_success
    end

    it "should expose current planning as @record" do
      do_request
      assigns[:record].should == @default_planning
    end
  end

  describe "responding to GET new" do
    def do_request
      get :new
    end

    it_should_require_login
    it_should_success_for_admins_without_duty
    it_should_success_for_users_with_role :scrum_master
    it_should_block_users_with_role :product_owner
    it_should_block_users_with_role :team_member
    it_should_block_users_without_duty_for_current_project

    it "should expose the new record as @record" do
      do_request
      assigns[:record].should be_new_record
    end

    it "should initialize the new planning with unexpected to true" do
      do_request
      assigns[:record].unexpected.should be_true
    end
  end

  describe "responding to GET edit" do
    before :each do
      Planning.stub!(:find).with("37").and_return(@default_planning)
    end

    def do_request
      get :edit, :id => "37"
    end

    it_should_require_login
    it_should_success_for_admins_without_duty
    it_should_success_for_users_with_role :scrum_master
    it_should_block_users_with_role :product_owner
    it_should_block_users_with_role :team_member
    it_should_block_users_without_duty_for_current_project

    it "should expose the requested Planning as @record" do
      do_request
      assigns[:record].should == @default_planning
    end
  end

  describe "responding to POST create" do
    before :each do
      Planning.destroy_all
    end

    def do_request
      post :create, :record => planning_required_values.merge(:story => @default_story.id.to_s, :sprint => @default_sprint.id.to_s)
    end

    it_should_require_login
    it_should_success_for_admins_without_duty
    it_should_success_for_users_with_role :scrum_master
    it_should_block_users_with_role :product_owner
    it_should_block_users_with_role :team_member
    it_should_block_users_without_duty_for_current_project

    it "should increase the number of Plannings" do
      lambda{ do_request }.should change{ Planning.count }.by(1)
    end
    
    describe "with invalid params" do
      def do_request
        post :create, :record => {:story => nil}
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
      @id = @default_planning.id
      @sprint = sprints(:sprint_p0_1)
      put :update, :id => @id, :record => {:sprint => @sprint.id.to_s}
    end

    it_should_require_login
    it_should_success_for_admins_without_duty
    it_should_success_for_users_with_role :scrum_master
    it_should_block_users_with_role :product_owner
    it_should_block_users_with_role :team_member
    it_should_block_users_without_duty_for_current_project

    describe "with valid params" do
      it "should update the requested record" do
        do_request
        Planning.find(@id).sprint.should == @sprint
      end

      it "should redirect to index" do
        do_request
        response_should_be_right
      end
    end
    
    describe "with invalid params" do
      def do_request
        @id = @default_planning.id
        put :update, :id => @id, :record => {:sprint => nil}
      end

      it "should expose the requested record as @record" do
        do_request
        assigns(:record).should == @default_planning
      end

      it "should re-render the 'update' template" do
        do_request
        response.should render_template('update')
      end
    end
  end

  describe "responding to DELETE destroy" do
    def do_request
      delete :destroy, :id => @default_planning.id 
    end

    it_should_require_login
    it_should_success_for_admins_without_duty
    it_should_success_for_users_with_role :scrum_master
    it_should_block_users_with_role :product_owner
    it_should_block_users_with_role :team_member
    it_should_block_users_without_duty_for_current_project

    it "should destroy the requested record" do
      lambda{ do_request }.should change{ Planning.count }.by(-1)
    end
  end
end

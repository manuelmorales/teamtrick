require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe StoriesController do
  fixtures :roles, :stories, :users, :projects, :tasks

  def mock_story(stubs={})
    stubs = {:project => mock_project}.merge stubs
    @mock_story ||= mock_model(Story, stubs)
  end

  def mock_project(stubs={})
    @mock_project ||= mock_model(Project,stubs)
  end

  before :each do
    login_as users(:admin)
    @current_project = mock_current_project
    @default_story = stories(:story_p0_0)
  end

  describe "responding to GET index" do
    def do_request
      get :index
    end

    it_should_require_login

    it "should expose all stories as @records" do
      do_request
      assigns[:records].should be_full_of(:stories)
    end

    it "should only expose stories with project = current_project" do
      do_request
      assigns[:records].map(&:project).uniq.should == [@current_project]
    end

    it "should only expose uncompleted stories" do
      do_request
      assigns[:records].map(&:completed?).uniq.should == [false]
    end

    it "should expose stories with no tasks" do
      do_request
      assigns[:records].should include(stories(:story_without_tasks_p0_10))
    end

    it "should expose stories with no tasks with hours_left = 0" do
      do_request
      assigns[:records].should include(stories(:story_p0_0))
    end
  end

  describe "responding to GET show" do
    def do_request
      get :show, :id => @default_story.id
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

    it "should expose current story as @record" do
      do_request
      assigns[:record].should == @default_story
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
    it_should_block_users_with_role :team_member
    it_should_block_users_without_duty_for_current_project

    it "should expose the new record as @record" do
      do_request
      assigns[:record].should be_new_record
    end

    it "should assign current_project to @record.project" do
      do_request
      assigns[:record].project.should == @current_project
    end

    it "should assign importance to @record" do
      do_request
      maximum_importance = @current_project.stories.map(&:importance).max
      assigns[:record].importance.should == maximum_importance + 1
    end
  end

  describe "responding to GET edit" do
    before :each do
      Story.stub!(:find).with("37").and_return(@default_story)
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

    it "should expose the requested Story as @record" do
      do_request
      assigns[:record].should == @default_story
    end
  end

  describe "responding to POST create" do
    def do_request
      post :create, :record => story_required_values.merge(:project => @current_project.id.to_s)
    end

    it_should_require_login
    it_should_success_for_admins_without_duty
    it_should_success_for_users_with_role :scrum_master
    it_should_success_for_users_with_role :product_owner
    it_should_block_users_with_role :team_member
    it_should_block_users_without_duty_for_current_project

    it "should increase the number of Stories" do
      lambda{ do_request }.should change{ Story.count }.by(1)
    end
    
    describe "with invalid params" do
      def do_request
        post :create, :record => {:name => nil}
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
      @id = @default_story.id
      @name = "NewName"
      put :update, :id => @id, :record => {:name => @name}
    end

    it_should_require_login
    it_should_success_for_admins_without_duty
    it_should_success_for_users_with_role :scrum_master
    it_should_success_for_users_with_role :product_owner
    it_should_success_for_users_with_role :team_member
    it_should_block_users_without_duty_for_current_project

    describe "importance" do
      before :each do
        @user = users(:any)
        login_as @user
      end

      def do_request
        @importance = 333
        put :update, :id => @default_story.id, :record => {:importance => @importance}
      end

      it "should success if user is Scrum Master" do
        @user.duty_for_project(@current_project).update_attribute :role_id, Role.scrum_master.id
        do_request
        @default_story.reload.importance.should == 333
      end

      it "should success if user is Product Owner" do
        @user.duty_for_project(@current_project).update_attribute :role_id, Role.product_owner.id
        do_request
        @default_story.reload.importance.should == 333
      end

      it "should success if user is Admin without Duty" do
        # for some reason this bypasses importance_authorized_for_update?
        # method
        @user = users(:admin)
        @user.duties.destroy_all

        do_request
        @default_story.reload.importance.should == 333
      end

      it "should fail if user is Team Member" do
        @user.duty_for_project(@current_project).update_attribute :role_id, Role.team_member.id
        do_request
        @default_story.reload.importance.should_not == 333
      end
    end

    describe "with valid params" do
      it "should update the requested record" do
        do_request
        Story.find(@id).name.should == @name
      end

      it "should redirect to index" do
        do_request
        response_should_be_right
      end
    end
    
    describe "with invalid params" do
      def do_request
        @id = @default_story.id
        @name = nil
        put :update, :id => @id, :record => {:name => @name}
      end

      it "should expose the requested record as @record" do
        do_request
        assigns(:record).should == @default_story
      end

      it "should re-render the 'update' template" do
        do_request
        response.should render_template('update')
      end
    end
  end

  describe "responding to DELETE destroy" do
    def do_request
      delete :destroy, :id => @default_story.id 
    end

    it_should_require_login
    it_should_success_for_admins_without_duty
    it_should_success_for_users_with_role :scrum_master
    it_should_success_for_users_with_role :product_owner
    it_should_block_users_with_role :team_member
    it_should_block_users_without_duty_for_current_project

    it "should destroy the requested record" do
      lambda{ do_request }.should change{ Story.count }.by(-1)
    end
  end
end

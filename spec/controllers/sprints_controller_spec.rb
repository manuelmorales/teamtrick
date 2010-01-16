require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SprintsController do
  fixtures :roles, :sprints, :users, :projects

  def mock_sprint(stubs={})
    stubs = {:project => mock_project}.merge stubs
    @mock_sprint ||= mock_model(Sprint, stubs)
  end

  def mock_project(stubs={})
    @mock_project ||= mock_model(Project,stubs)
  end

  before :each do
    login_as users(:admin)
    controller.stub! :current_project => mock_project(:unsaved? => false)
    @default_record = sprints(:sprint_p0_0)
    @current_project = mock_current_project
  end


  describe "responding to GET index" do
    def do_request
      get :index
    end

    it_should_require_login
  end

  describe "responding to GET show" do
    def do_request
      get :show, :id => @default_record.id
    end

    it_should_require_login
    it_should_block_users_without_duty_for_current_project

    it "should redirect to show_planning if Sprint status is planning" do
      @default_record.update_attribute :start_date, Date.today + 1.days
      @default_record.update_attribute :finish_date, Date.today + 2.days
      @default_record.plannings.destroy_all

      do_request
      response.should redirect_to(project_sprint_planning_path(@default_record.project, @default_record))
    end

    it "should render message if Sprint status is planning and the Sprint before is not closed" do
      build_object(Sprint, :project => @default_record.project,
       :number_of_workdays => 2,
       :start_date => Date.today + 1.days, 
       :finish_date => Date.today + 2.days).save!
      @default_record.update_attribute :start_date, Date.today + 3.days
      @default_record.update_attribute :finish_date, Date.today + 4.days
      @default_record.plannings.destroy_all

      do_request
      response.should render_template("message/index")
    end

    it "should redirect to show_closed if Sprint status is closed" do
      do_request
      response.should redirect_to(project_sprint_closed_path(@default_record.project, @default_record))
    end
  end

  describe "responding to GET show_closed" do
    def do_request
      get :show_closed, :id => @default_record.id
    end

    it_should_require_login
    it_should_block_users_without_duty_for_current_project
    it_should_success_for_admins_without_duty
    it_should_success_for_users_with_role :scrum_master
    it_should_success_for_users_with_role :team_member
    it_should_success_for_users_with_role :product_owner

    it "should expose current record as @record" do
      do_request
      assigns[:record].should == @default_record
    end
  end

  describe "responding to GET show_planning" do
    def do_request
      get :show_planning, :id => @default_record.id
    end

    it_should_require_login
    it_should_render_message_to_users_without_duty_for_current_project
    it_should_success_for_admins_without_duty
    it_should_success_for_users_with_role :scrum_master

    it "should expose current record as @record" do
      do_request
      assigns[:record].should == @default_record
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

    it "should assign current_project to @record.project" do
      p = mock_project
      controller.stub!(:current_project => p)
      do_request
      assigns[:record].project.should == p
    end
  end

  describe "responding to GET edit" do
    def do_request
      get :edit, :id => @default_record.id
    end

    it_should_require_login
    it_should_success_for_admins_without_duty
    it_should_success_for_users_with_role :scrum_master
    it_should_block_users_with_role :product_owner
    it_should_block_users_with_role :team_member
    it_should_block_users_without_duty_for_current_project
  end

  describe "responding to POST create" do
    def do_request
      post :create, :record => sprint_required_values.merge(:project => @current_project.id.to_s)
    end

    it_should_require_login
    it_should_success_for_admins_without_duty
    it_should_success_for_users_with_role :scrum_master
    it_should_block_users_with_role :product_owner
    it_should_block_users_with_role :team_member
    it_should_block_users_without_duty_for_current_project
  end

  describe "responding to PUT update" do
    def do_request
      put :update, :id => @default_record.id, :record => { :estimated_focus_factor => 0.9}
    end

    it_should_require_login
    it_should_success_for_admins_without_duty
    it_should_success_for_users_with_role :scrum_master
    it_should_block_users_with_role :product_owner
    it_should_block_users_with_role :team_member
    it_should_block_users_without_duty_for_current_project
  end

  describe "responding to DELETE destroy" do
    def do_request
      delete :destroy, :id => @default_record.id
    end

    it_should_require_login
    it_should_success_for_admins_without_duty
    it_should_success_for_users_with_role :scrum_master
    it_should_block_users_with_role :product_owner
    it_should_block_users_with_role :team_member
    it_should_block_users_without_duty_for_current_project
  end

  describe "responding to POST finish_planning" do
    fixtures :stories, :tasks

    before :each do
      @sprint = Sprint.create :start_date => Date.today - 1.weeks,
        :finish_date => Date.today + 1.weeks,
        :estimated_focus_factor => 0.7,
        :project => @current_project
      @commitment = Commitment.create :user => users(:admin), :sprint => @sprint, :level => 100
      Story.all.select{|s| s.hours_left == nil}.each(&:destroy)
    end

    def do_request
      post :finish_planning, :id => @sprint.id
    end

    it_should_require_login
    it_should_success_for_admins_without_duty
    it_should_success_for_users_with_role :scrum_master
    it_should_block_users_with_role :product_owner
    it_should_block_users_with_role :team_member
    it_should_block_users_without_duty_for_current_project

    it "should create Plannings" do
      do_request
      @sprint.plannings.should_not be_empty
    end

    it "should remove old Plannings" do
      @old_planning = Planning.create :sprint => @sprint, :story => @sprint.factible_stories.first
      do_request
      @sprint.plannings.should_not include(@old_planning)
    end

    it "should create the new plannings with unexpected to false" do
      do_request
      @sprint.plannings.map(&:unexpected).uniq.should == [false]
    end

    it "should render message if there are no Stories defined yet" do
      Story.destroy_all
      do_request
      response.should render_template('message/index')
    end

    it "should render message if there are no Commitments for that Sprint yet" do
      @sprint.commitments.destroy_all
      do_request
      response.should render_template('message/index')
    end

    it "should render message if there are no factible_stories for that Sprint" do
      @commitment.update_attribute :level, 0
      do_request
      response.should render_template('message/index')
    end

    it "should render message if a Story has storypoints set to nil" do
      @sprint.factible_stories.first.update_attribute :storypoints, nil
      do_request
      response.should render_template('message/index')
    end

    it "should render message if a Story has no Tasks" do
      @sprint.factible_stories.first.tasks.destroy_all
      do_request
      response.should render_template('message/index')
    end
  end

  describe "responding to GET day" do
    def do_request
      get :day, :sprint_id => @default_record.id, :project_id => @default_record.project_id, :day => 5
    end

    it_should_require_login

    it "should redirect to the corresponding stats_for_date action" do
      @default_record.update_attribute :start_date, Date.parse("3000-12-01")
      @default_record.update_attribute :finish_date, Date.parse("3000-12-31")

      do_request
      response.should redirect_to(project_stats_for_date_path(@default_record.project, "3000-12-06"))
    end
  end
end

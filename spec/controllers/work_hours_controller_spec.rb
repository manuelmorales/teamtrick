require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe WorkHoursController do
  fixtures :roles, :work_hours, :tasks, :stories, :users, :duties, :projects

  def mock_work_hour(stubs={})
    @mock_work_hour ||= build_object(WorkHour, stubs)
  end

  def mock_user(stubs={})
    @mock_user ||= build_object(User, stubs)
  end

  def mock_task(stubs={})
    @mock_task ||= build_object(Task, stubs)
  end

  def mock_story(stubs={})
    @mock_sprint ||= build_object(Story, stubs)
  end

  before :each do
    login_as users(:admin)
    @current_project = mock_current_project
    @default_work_hour = work_hours(:work_hour_p0_s0_t0_0)
    @default_task = @default_work_hour.task
    @default_story = @default_work_hour.task.story
    @default_user = @default_work_hour.user
  end

  describe "responding to GET index" do
    def do_request
      get :index
    end

    it_should_require_login

    it "should expose all work_hours as @records" do
      do_request
      assigns[:records].should be_full_of(:work_hours)
    end
  end

  describe "responding to GET show" do
    def do_request
      get :show, :id => @default_work_hour.id
    end

    it_should_require_login
    it_should_block_users_without_duty_for_current_project
    it_should_success_for_admins_without_duty
    it_should_success_for_users_with_role :team_member
    it_should_success_for_users_with_role :scrum_master
    it_should_success_for_users_with_role :product_owner

    it "should expose current work_hour as @record" do
      do_request
      assigns[:record].should == @default_work_hour
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
      WorkHour.stub!(:find).with("37").and_return(@default_work_hour)
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

    it "should expose the requested WorkHour as @record" do
      do_request
      assigns[:record].should == @default_work_hour
    end
  end

  describe "responding to POST create" do
    def do_request
      post :create, :record => work_hour_required_values.merge(:task => @default_task.id.to_s, :user => @default_user.id.to_s)
    end

    it_should_require_login
    it_should_success_for_admins_without_duty
    it_should_success_for_users_with_role :scrum_master
    it_should_success_for_users_with_role :product_owner
    it_should_success_for_users_with_role :team_member
    it_should_block_users_without_duty_for_current_project

    it "should increase the number of WorkHours" do
      lambda{ do_request }.should change{ WorkHour.count }.by(1)
    end

    it "should set old_hours_left to its task's hours_left" do
      do_request
      assigns(:record).old_hours_left.should == assigns(:record).task.hours_left
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
      @id = @default_work_hour.id
      @hours = 33
      put :update, :id => @id, :record => {:hours => @hours}
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
        WorkHour.find(@id).hours.should == @hours
      end

      it "should redirect to index" do
        do_request
        response_should_be_right
      end
    end
    
    describe "with invalid params" do
      def do_request
        @id = @default_work_hour.id
        @hours = nil
        put :update, :id => @id, :record => {:hours => @hours}
      end

      it "should expose the requested record as @record" do
        do_request
        assigns(:record).should == @default_work_hour
      end

      it "should re-render the 'update' template" do
        do_request
        response.should render_template('update')
      end
    end
  end

  describe "responding to DELETE destroy" do
    def do_request
      delete :destroy, :id => @default_work_hour.id 
    end

    it_should_require_login
    it_should_success_for_admins_without_duty
    it_should_success_for_users_with_role :scrum_master
    it_should_success_for_users_with_role :product_owner
    it_should_success_for_users_with_role :team_member
    it_should_block_users_without_duty_for_current_project

    it "should destroy the requested record" do
      lambda{ do_request }.should change{ WorkHour.count }.by(-1)
    end
  end
end

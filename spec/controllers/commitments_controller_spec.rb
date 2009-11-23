require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe CommitmentsController do
  fixtures :roles, :commitments, :sprints, :users, :projects

  def mock_commitment(stubs={})
    stubs = {:project => mock_project, :user => mock_user, :sprint => mock_sprint}.merge stubs
    @mock_commitment ||= mock_model(Commitment, stubs)
  end

  def mock_project(stubs={})
    @mock_project ||= mock_model(Project, stubs)
  end

  def mock_user(stubs={})
    @mock_user ||= mock_model(User, stubs)
  end

  def mock_sprint(stubs={})
    @mock_sprint ||= mock_model(Sprint, stubs)
  end

  before :each do
    login_as users(:admin)
    @current_project = mock_current_project
    @default_commitment = commitments(:commitment_u0_p0_s0)
    @default_user = users(:any)
    @default_sprint = sprints(:sprint_p0_0)
  end

  describe "responding to GET index" do
    def do_request
      get :index
    end

    it_should_require_login

    it "should expose all commitments as @records" do
      do_request
      assigns[:records].should be_full_of(:commitments)
    end
  end

  describe "responding to GET show" do
    def do_request
      get :show, :id => @default_commitment.id
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

    it "should expose current commitment as @record" do
      do_request
      assigns[:record].should == @default_commitment
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
  end

  describe "responding to GET edit" do
    before :each do
      Commitment.stub!(:find).with("37").and_return(@default_commitment)
    end

    def do_request
      get :edit, :id => "37"
    end

    it_should_require_login
    it_should_success_for_admins_without_duty
    it_should_success_for_users_with_role :scrum_master
    it_should_success_for_users_with_role :product_owner
    it_should_block_users_with_role :team_member
    it_should_block_users_without_duty_for_current_project

    it "should expose the requested Commitment as @record" do
      do_request
      assigns[:record].should == @default_commitment
    end
  end

  describe "responding to POST create" do
    before :each do
      @default_user.commitments.destroy_all
    end

    def do_request
      post :create, :record => commitment_required_values.merge(:user => @default_user.id.to_s, :sprint => @default_sprint.id.to_s)
    end

    it_should_require_login
    it_should_success_for_admins_without_duty
    it_should_success_for_users_with_role :scrum_master
    it_should_success_for_users_with_role :product_owner
    it_should_block_users_with_role :team_member
    it_should_block_users_without_duty_for_current_project

    it "should increase the number of Commitments" do
      lambda{ do_request }.should change{ Commitment.count }.by(1)
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
      @id = @default_commitment.id
      @level = 33
      put :update, :id => @id, :record => {:level => @level}
    end

    it_should_require_login
    it_should_success_for_admins_without_duty
    it_should_success_for_users_with_role :scrum_master
    it_should_success_for_users_with_role :product_owner
    it_should_block_users_with_role :team_member
    it_should_block_users_without_duty_for_current_project

    describe "with valid params" do
      it "should update the requested record" do
        do_request
        Commitment.find(@id).level.should == @level
      end

      it "should redirect to index" do
        do_request
        response_should_be_right
      end
    end
    
    describe "with invalid params" do
      def do_request
        @id = @default_commitment.id
        @level = nil
        put :update, :id => @id, :record => {:level => @level}
      end

      it "should expose the requested record as @record" do
        do_request
        assigns(:record).should == @default_commitment
      end

      it "should re-render the 'update' template" do
        do_request
        response.should render_template('update')
      end
    end
  end

  describe "responding to DELETE destroy" do
    def do_request
      delete :destroy, :id => @default_commitment.id 
    end

    it_should_require_login
    it_should_success_for_admins_without_duty
    it_should_success_for_users_with_role :scrum_master
    it_should_success_for_users_with_role :product_owner
    it_should_block_users_with_role :team_member
    it_should_block_users_without_duty_for_current_project

    it "should destroy the requested record" do
      lambda{ do_request }.should change{ Commitment.count }.by(-1)
    end
  end
end

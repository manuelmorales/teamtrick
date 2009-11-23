require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe DutiesController do
  fixtures :roles, :duties, :users, :projects

  def mock_duty(stubs={})
    stubs = {:project => mock_project}.merge stubs
    @mock_duty ||= mock_model(Duty, stubs)
  end

  def mock_project(stubs={})
    @mock_project ||= mock_model(Project,stubs)
  end

  before :each do
    login_as users(:admin)
    @current_project = mock_current_project
    @default_user = users(:default)
    @default_duty = duties(:duty_p0_u0)
  end

  describe "responding to GET index" do
    def do_request
      get :index
    end

    it_should_require_login

    it "should expose all duties as @records" do
      do_request
      assigns[:records].should be_full_of(:duties)
    end
  end

  describe "responding to GET show" do
    def do_request
      get :show, :id => @default_duty.id
    end

    it_should_require_login
    it_should_block_users_without_duty_for_current_project

    it "should not block admins anyway" do
      user = users(:admin)
      user.duties.destroy_all
      login_as user
      get :show, :id => duties(:duty_p0_u2).id
      response.should be_success
    end

    it "should success for a normal user" do
      login_as users(:any)
      do_request
      response.should be_success
    end

    it "should expose current Duty as @record" do
      do_request
      assigns[:record].should == @default_duty
    end
  end

  describe "responding to GET new" do
    def do_request
      get :new
    end

    it_should_require_login
    it_should_success_for_admins_without_duty
    it_should_require_admin

    it "should expose the new record as @record" do
      do_request
      assigns[:record].should be_new_record
    end

    it "should assign current_project to @record.project" do
      do_request
      assigns[:record].project.should == @current_project
    end
  end

  describe "responding to GET edit" do
    before :each do
      @default_duty = duties(:duty_p0_u1)
    end

    def do_request
      get :edit, :id => @default_duty.id
    end

    it_should_require_login
    it_should_success_for_admins_without_duty
    it_should_require_admin

    it "should expose the requested Duty as @record" do
      do_request
      assigns[:record].should == @default_duty
    end
  end

  describe "responding to POST create" do
    before :each do
      @default_user.duties.destroy_all
    end

    def do_request
      post :create, :record => commitment_required_values.merge(
        :user => @default_user.id.to_s, 
        :project => @current_project.id.to_s,
        :role => Role.team_member.id.to_s
      )
    end

    it_should_require_login
    it_should_success_for_admins_without_duty
    it_should_require_admin

    it "should increase the number of Commitments" do
      lambda{ do_request }.should change{ Duty.count }.by(1)
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
    before :each do
      @id = @default_duty.id
      @role_id = Role.team_member.id
    end

    def do_request
      put :update, :id => @id, :record => {:role => @role_id.to_s}
    end

    it_should_require_login
    it_should_require_admin

    describe "with valid params" do
      it "should update the requested record" do
        do_request
        Duty.find(@id).role_id.should == @role_id
      end

      it "should redirect to index" do
        do_request
        response_should_be_right
      end
    end
    
    describe "with invalid params" do
      def do_request
        @id = @default_duty.id
        @role_id = nil
        put :update, :id => @id, :record => {:role => nil}
      end

      it "should expose the requested record as @record" do
        do_request
        assigns(:record).should == @default_duty
      end

      it "should re-render the 'update' template" do
        do_request
        response.should render_template('update')
      end
    end
  end

  describe "responding to DELETE destroy" do
    def do_request
      delete :destroy, :id => @default_duty.id
    end

    it_should_require_login
    it_should_require_admin

    it "should destroy the requested record" do
      lambda{ do_request }.should change{ Duty.count }.by(-1)
    end
  end
end

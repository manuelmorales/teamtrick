require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe UsersController do
  fixtures :roles, :users

  def mock_user(stubs={})
    @mock_user ||= mock_model(User, stubs)
  end

  before :each do
    login_as users(:admin)
  end

  def default_user
    @default_user ||= users(:default)
  end

  describe "responding to GET index" do
    def do_request
      get :index
    end

    it_should_require_login

    it "should expose users as @records" do
      do_request
      assigns[:records].should be_full_of(:users)
    end
  end

  describe "responding to GET show" do
    def do_request
      get :show, :id => default_user.id
    end

    it_should_require_login

    it "should expose the requested user as @record" do
      do_request
      assigns[:record].should == default_user
    end
  end

  describe "responding to GET new" do
    def do_request
      get :new
    end

    it_should_require_login
    it_should_require_admin

    it "should expose a new user as @record" do
      do_request
      assigns[:record].should be_new_record
    end
  end

  describe "responding to GET edit" do
    def do_request
      get :edit, :id => default_user.id
    end

    it_should_require_login
    it_should_require_admin
    
    it "should let an user to edit himself" do
      login_as default_user
      do_request
      response.should be_success
    end

    it "should expose the requested user as @record" do
      do_request
      assigns[:record].should == default_user
    end
  end

  describe "responding to POST create" do
    def do_request
      post :create, :record => user_required_values
    end

    it_should_require_login
    it_should_require_admin

    describe "with valid params" do
      it "should expose a newly created user as @record" do
        do_request
        assigns(:record).should_not be_new_record
        assigns(:record).login.should == user_required_values[:login]
      end

      it "should redirect to index" do
        do_request
        response.should redirect_to(users_path)
      end
    end
    
    describe "with invalid params" do
      it "should expose a newly created but unsaved user as @record" do
        post :create, :record => { :real_name => "real name", :login => nil}
        assigns(:record).should_not be_nil
        assigns(:record).real_name.should == "real name"
      end

      it "should re-render the 'create' template" do
        post :create, :record => {}
        response.should render_template('create')
      end
    end
  end

  describe "responding to PUT update" do
    describe "with valid params" do
      def do_request
        put :update, :id => default_user.id, :record => {:login => "new_login"}
      end

      it_should_require_login
      it_should_require_admin

      it "should let an user to update himself" do
        login_as default_user
        do_request
        User.find(default_user.id).login.should == "new_login"
      end
      
      it "should not let an user to disable himself" do
        put :update, :id => users(:admin).id, :record => {:disabled => true}
        User.find_by_id(users(:admin).id).should_not be_disabled
      end
      
      it "should not let a normal user make admin himself" do
        user = users(:any)
        login_as user
        put :update, :id => user.id, :record => {:admin => true}
        User.find_by_id(user.id).should_not be_admin
      end
      
      it "should not let an admin to disable his admin attribute himself" do
        user = users(:admin)
        login_as user
        put :update, :id => user.id, :record => {:admin => false}
        User.find_by_id(user.id).should be_admin
      end
      
      it "should let an admin to change admin attribute for another user" do
        login_as users(:admin)
        user = users(:any)
        put :update, :id => user.id, :record => {:admin => true}
        User.find_by_id(user.id).should be_admin
      end

      it "should update the requested user" do
        do_request
        User.find(default_user.id).login.should == "new_login"
      end

      it "should expose the requested user as @record" do
        do_request
        assigns(:record).should == default_user
      end

      it "should redirect to index" do
        do_request
        response.should redirect_to(users_path)
      end
    end
    
    describe "with invalid params" do
      def do_request
        put :update, :id => default_user.id, :record => {:login => nil}
      end

      it_should_require_login
      it_should_require_admin

      it "should expose the requested user as @record" do
        do_request
        assigns(:record).should == default_user
      end

      it "should re-render the 'update' template" do
        do_request
        response.should render_template('update')
      end
    end
  end

  describe "responding to DELETE destroy" do
    def do_request
      delete :destroy, :id => default_user.id
    end

    it_should_require_login
    it_should_require_admin

    it "should not destroy the requested user" do
      do_request
      User.find_by_id(default_user.id).should_not be_nil
    end

    it "should disable the requested user" do
      do_request
      User.find_by_id(default_user.id).should be_disabled
    end

    it "should not let an user to disable himself" do
      pending
      # ActiveScaffold do not calls authorized_for_destroy?
      # with the exisstent record on destroy, only
      # when listing
      user = users(:admin)
      login_as user
      delete :destroy, :id => user.id
      User.find(user.id).should_not be_disabled
    end
  end
end

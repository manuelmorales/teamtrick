require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe AccountController do
  fixtures :users, :roles

  def mock_user(stubs={})
    @mock_user ||= mock_model(User, stubs)
  end

  def auth_token(token)
    CGI::Cookie.new('name' => 'auth_token', 'value' => token)
  end

  def cookie_for(user)
    auth_token users(user).remember_token
  end

  describe "responding to login" do
    describe "when successful" do
      def do_request
        @user = User.find_by_login('user_0')
        post :login, :login => 'user_0', :password => 'pink-panther'
      end

      it "should login and redirect to projects controller" do
        do_request
        session[:user].should == @user.id
      end

      it "should redirect to \"back\"" do
        back = "http://test.host/users"
        session[:return_to] = back
        do_request
        response.should redirect_to(back)
      end

      it "should redirect to \"/projects\" controller if there is no \"back\"" do
        do_request
        response.should redirect_to(projects_url)
      end

      it "should set flash[:notice] if login was possible" do
        do_request
        flash[:notice].should_not be_nil
      end
    end

    describe "when fail" do
      def do_request
        @user = User.find_by_login('user_0')
        post :login, :login => 'user_0', :password => 'wrong-password'
      end

      it "should fail login and not redirect" do
        do_request
        session[:user].should be_nil
        response.should be_success
      end

      it "should set flash[:error] if login wasn't possible" do
        do_request
        flash[:error].should_not be_nil
      end

      it "should render \"login\" template" do
        do_request
        response.should render_template('login')
      end

      it "should render \"not_logged\" layout" do
        do_request
        response.layout.should == 'layouts/not_logged'
      end
    end

    describe "with verb GET" do
      def do_request
        get :login
      end

      it "should redirect to signup if there are no admins and set flash[:notice]" do
        User.find_by_admin(true).destroy
        do_request
        flash[:notice].should_not be_nil
        response.should redirect_to(:action => "signup")
      end

      it "should render \"not_logged\" layout" do
        do_request
        response.layout.should == 'layouts/not_logged'
      end
    end
  end

  describe "responding to signup" do
    describe "if there already are admins" do
      it "should redirect and show error" do
        get :signup
        response.should redirect_to(message_path)
        flash[:error].should_not be_nil
      end
    end

    describe "if there are no admins" do
      before :each do
        users(:admin).destroy
      end

      describe "when request is GET" do
        def do_request
          get :signup
        end

        it "should render form" do
          do_request
          response.should render_template("signup")
          response.should be_success
        end

        it "should expose a new user as @user" do
          do_request
          assigns[:user].should be_new_record
        end
      end

      describe "when request is POST" do
        describe "with valid params" do
          def do_request
            post :signup, :user => user_required_values
          end

          it "should login the new user" do
            do_request
            session[:user].should == assigns[:user].id
          end

          it "should make the user admin" do
            do_request
            User.find(session[:user]).should be_admin
          end

          it "should redirect to projects index" do
            do_request
            response.should redirect_to(projects_path)
          end
        end

        describe "with invalid params" do
          def do_request
            post :signup, :user => {}
          end
          it "should expose a newly created but unsaved user as @user" do
            do_request
            assigns(:user).should_not be_nil
          end

          it "should re-render the 'signup' template" do
            do_request
            response.should render_template('signup')
          end
        end
      end
    end
  end

  describe "responding to logout" do
    it "should logout" do
      login_as User.find_by_login('user_0')
      get :logout
      session[:user].should be_nil
    end
    
    it "should redirect to login" do
      login_as User.find_by_login('user_0')
      get :logout
      response.should redirect_to(login_path)
    end
  end

  describe "when managing auth_token" do
    it "should delete token on logout" do
      login_as User.find_by_login('user_0')
      get :logout

      # originally this was:
      # assert_equal @response.cookies["auth_token"], []
      # but now it returns nil instead of []
      response.cookies["auth_token"].should be_blank
    end

    it "should_remember_me" do
      post :login, :login => 'user_0', :password => 'pink-panther', :remember_me => "1"
      response.cookies["auth_token"].should_not be_nil
    end

    it "should not remember me" do
      post :login, :login => 'user_0', :password => 'pink-panther', :remember_me => "0"
      response.cookies["auth_token"].should be_nil
    end

    it "should login with cookie" do
      users(:admin).remember_me
      request.cookies["auth_token"] = cookie_for(:admin)
      get :index
      @controller.should be_logged_in
    end

    it "should fail expired cookie login" do
      users(:admin).remember_me
      users(:admin).update_attribute :remember_token_expires_at, 5.minutes.ago
      request.cookies["auth_token"] = cookie_for(:admin)
      get :index
      @controller.should_not be_logged_in
    end

    it "should fail cookie login" do
      users(:admin).remember_me
      request.cookies["auth_token"] = auth_token('invalid_auth_token')
      get :index
      @controller.should_not be_logged_in
    end
  end
end

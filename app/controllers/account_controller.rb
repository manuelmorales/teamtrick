class AccountController < ApplicationController
  skip_before_filter :load_current_user
  skip_before_filter :load_current_project
  skip_before_filter :login_required
  skip_before_filter :check_permissions

  def index
    render :text => ""
  end

  def signup
    unless there_are_no_admins
      flash[:error] = "Users must be created by Admins"
      redirect_to message_path and return
    end

    @user = User.new(params[:user])
    render :layout => "not_logged"  and return unless request.post?

    @user.save!
    @user.update_attribute :admin, true
    self.current_user = @user
    redirect_back_or_default(projects_path)
    flash[:notice] = "Thanks for signing up!"
  rescue ActiveRecord::RecordInvalid
    render :layout => "not_logged" 
  end

  def login
    if there_are_no_admins
      redirect_to :action => "signup" 
      flash[:notice] = "Welcome! Please create the first user, that will be admin"
      return 
    end

    render(:layout => 'not_logged') and return unless request.post?

    self.current_user = User.authenticate(params[:login], params[:password])
    if logged_in?
      if params[:remember_me] == "1"
        self.current_user.remember_me
        cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
      end
      redirect_back_or_default(projects_path)
      flash[:notice] = "Logged in successfully"
    else
      flash[:error] = "Wrong user name or password"
      render(:layout => 'not_logged') and return
    end
  end

  def logout
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = "You have been logged out."
    redirect_back_or_default(login_path)
  end
end

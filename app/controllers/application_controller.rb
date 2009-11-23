# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include AuthenticatedSystem
  include GraphDataSystem

  # Commented this because helper methods where conflicting
  # when overriding ActiveScaffold fields
  # helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '87b0dcb17682a3fe4ecbd024e8535924'

  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  filter_parameter_logging :password

  # Be sure to include AuthenticationSystem in Application Controller instead
  # If you want "remember me" functionality, add this before_filter to Application Controller
  before_filter :login_from_cookie
  before_filter :login_required
  # before_filter :check_permissions

  helper_method :current_user, 
    :current_project, 
    :plays_current_user_role?,
    :current_user_is_admin_or?,
    :default_title

  rescue_from ActiveScaffold::RecordNotAllowed, :with => :permissions_error
  rescue_from ActiveScaffold::ActionNotAllowed, :with => :permissions_error

  private

  # TODO AuthenticatedSystem#login_required
  # must be used instead of this
  def require_login
    if !session[:user]
      flash[:notice] = 'Please log in'
      redirect_to login_path
      return false
    end
  end

  def current_project
    id = params[:controller] == "projects" ?  params[:id] : params[:project_id]
    @current_project ||= (id && Project.find(id.to_i))
  end

  def current_role
    current_user.duties.with_project(current_project).first.role
  end

  def plays_current_user_role? *role_list
    role_list.map(&:to_s).include?(current_role.permalink) rescue false
  end

  def current_user_is_admin_or? *role_list
    current_user.admin? || plays_current_user_role?(*role_list)
  end


  def default_title
    @default_title ||= case action_name
    when "index"
      "Listing #{controller_name.humanize}"
    else
      "#{action_name.humanize} #{controller_name.singularize.humanize}"
    end
  end

  def there_are_no_admins
    User.find_by_admin(true) ? false : true
  end

  def permissions_error e
    if [ActiveScaffold::ActionNotAllowed, ActiveScaffold::RecordNotAllowed].include? e.class
      flash[:error] = "Action not allowed."
    else
      flash[:error] = "Internal server error."
    end

    redirect_to message_path
  end

  def render_message message
    @message = message
    render :template => 'message/index'
  end

  def do_new_with_project
    @record = active_scaffold_config.model.new :project => current_project
    apply_constraints_to_record(@record)
    params[:eid] = @old_eid if @remove_eid
    @record
  end
end

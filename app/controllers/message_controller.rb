class MessageController < ApplicationController
  skip_before_filter :load_current_user
  skip_before_filter :load_current_project
  skip_before_filter :login_required
  skip_before_filter :check_permissions

  def index
  end
end

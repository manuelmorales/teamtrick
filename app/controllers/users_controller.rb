class UsersController < ApplicationController
  active_scaffold do |config|
    config.columns = [
      :real_name, 
      :login, 
      :email, 
      :available_hours_per_week, 
      :password, 
      :password_confirmation,
      :admin,
      :disabled,
    ]

    config.columns[:duties].form_ui = :select
    config.columns[:disabled].form_ui = :checkbox
    config.columns[:admin].form_ui = :checkbox
    config.columns[:password].form_ui = :password
    config.columns[:password_confirmation].form_ui = :password

    config.list.columns = [:real_name, :email]
    config.show.columns = [:real_name, :login, :email, :admin, :available_hours_per_week, :disabled]
    config.create.columns = config.update.columns = [
      :real_name, 
      :login, 
      :email, 
      :admin,
      :available_hours_per_week, 
      :password, 
      :password_confirmation
    ]
    config.update.columns << :disabled

    config.columns[:real_name].set_link :show
    config.show.link = false
    config.list.label = "&nbsp;"
    config.delete.link.label = "Disable"
  end

  def destroy
    User.find(params[:id]).update_attributes({:disabled => true })
  end

  protected

  def create_authorized?
    current_user.admin?
  end

  def read_authorized?
    current_user.admin?
  end

  # Model will take care of this
  def update_authorized?
    true
  end
end

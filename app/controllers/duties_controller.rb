class DutiesController < ApplicationController
  before_filter :column_selection

  active_scaffold do |config|
    config.columns = [:user, :role, :project]
    config.columns[:user].form_ui = :select
    config.columns[:role].form_ui = :select
    config.columns[:role].clear_link
    config.columns[:user].description = 'You can create new users <a href="/users/">here</a>.'
    config.show.columns = [:user, :role]
    config.list.columns =  [:user, :role]
    config.list.label = "&nbsp;"
    config.show.link = false
    config.search.link = false
    config.create.link.label = "Add user"
    config.create.label = "Add user"
  end

  protected

  def column_selection
    if params[:mode] == 'mini'
      active_scaffold_config.columns[:user].clear_link
      %W{new edit delete}.each do |action|
        active_scaffold_config.action_links.delete action
      end
      active_scaffold_config.list.no_entries_message = 
        "No user plays a role on this project yet.<br /><br /> Click <em>Users & Roles</em> to start adding them."
    else
      active_scaffold_config.action_links << ActiveScaffold::Config::Create.link
      active_scaffold_config.action_links << ActiveScaffold::Config::Update.link
      active_scaffold_config.action_links << ActiveScaffold::Config::Delete.link
      active_scaffold_config.list.no_entries_message = 
        "No user plays a role on this project yet.<br /> Click <em>Add user</em> to add one."
    end
  end

  def do_new
    do_new_with_project
  end

  def show_authorized?
    current_user.projects_to_show.include? current_project
  end

  def create_authorized?
    current_user.admin?
  end

  def update_authorized?
    current_user.admin?
  end

  def delete_authorized?
    current_user.admin?
  end
end

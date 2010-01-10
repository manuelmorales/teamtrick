class StoriesController < ApplicationController
  before_filter :column_selection
  before_filter :enable_inplace_edit
  helper_method :factible_stories

  active_scaffold do |config|
    config.columns = [:importance, :name, :description, :storypoints, :estimation, :hours_left, :project]

    config.list.columns.exclude [:description, :project, :hours_left, :estimation]
    config.create.columns = [:importance, :name, :description, :storypoints, :project]
    config.update.columns = [:importance, :name, :description, :storypoints, :project]
    config.show.columns.exclude [:importance, :name, :description, :estimation, :project]

    config.list.sorting = {:importance => :desc}
    config.columns[:importance].label = "Imp."
    config.columns[:importance].description = "Bigger means more important"
    config.columns[:importance].css_class = "big-bold"
    config.columns[:hours_left].label = "Hours left (task-based)"
    config.columns[:name].set_link :show
    config.list.label = "&nbsp;"
    config.show.link = false
    config.search.link = false

    config.columns[:importance].options = {:size => 3}
    config.columns[:storypoints].options = {:size => 3}
    config.columns[:description].options = {:rows => 4, :truncate => 30}

    config.list.per_page = 12

    config.subform.layout = :vertical
  end

  def new
    do_new
    @record.importance = (Story.with_project(current_project).maximum(:importance) || 0) + 1
    respond_to_action(:new)
  end

  def update
    do_update
    do_list
    respond_to_action(:update)
  end

  def refresh_table
    do_list
  end

  def update_column
    do_update_column
    do_list
  end

  def create
    do_create
    @insert_row = params[:parent_controller].nil?
    do_list
    respond_to_action(:create)
  end

  protected

  def factible_stories
    if sprint_id = params[:sprint]
      @factible_stories ||= Sprint.find(sprint_id).factible_stories
    else
      []
    end
  end

  def column_selection
    if params[:mode] == 'planning'
      active_scaffold_config.list.columns.exclude active_scaffold_config.list.columns.map(&:name)
      active_scaffold_config.list.columns. << [:importance, :name, :hours_left]
      restore_links_and_no_entries_message
    elsif params[:mode] == 'mini'
      active_scaffold_config.list.columns.exclude active_scaffold_config.list.columns.map(&:name)
      active_scaffold_config.list.columns. << [:name_without_link, :hours_left]
      %W{new edit delete refresh_table}.each{|action| active_scaffold_config.action_links.delete action}
      active_scaffold_config.list.no_entries_message = "No story has been created yet.<br /><br /> Click <em>Backlog</em> to start adding them."
    else
      active_scaffold_config.list.columns.exclude active_scaffold_config.list.columns.map(&:name)
      active_scaffold_config.list.columns. << [:importance, :name, :storypoints]
      restore_links_and_no_entries_message
    end
  end

  def restore_links_and_no_entries_message
    active_scaffold_config.action_links << ActiveScaffold::Config::Create.link
    active_scaffold_config.action_links << ActiveScaffold::Config::Update.link
    active_scaffold_config.action_links << ActiveScaffold::Config::Delete.link
    active_scaffold_config.action_links << ActiveScaffold::DataStructures::ActionLink.new(:refresh, :action => 'refresh_table', :position => false)
    active_scaffold_config.list.no_entries_message = "No story has been created yet.<br /> Click <em>Create new</em> to add one."
  end

  def enable_inplace_edit
    active_scaffold_config.columns[:importance].inplace_edit = true if current_user_is_admin_or?(:product_owner, :scrum_master)
  end

  def do_new
    @record = do_new_with_project
    @record.importance = Story.maximum(:importance) + 1
  end

  def custom_finder_options
    Story.uncompleted.with_project(current_project).scope :find
  end

  def show_authorized?
    current_user.projects_to_show.include? current_project
  end

  def create_authorized?
    current_user_is_admin_or?(:product_owner, :scrum_master)
  end

  def update_authorized?
    current_user_is_admin_or?(:product_owner, :scrum_master, :team_member)
  end

  def delete_authorized?
    current_user_is_admin_or?(:product_owner, :scrum_master)
  end
end

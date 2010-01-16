class SprintsController < ApplicationController
  before_filter :column_selection
  helper_method :show_planning_authorized?

  active_scaffold do |config|
    config.search.link = false
    config.list.sorting = {:start_date => :desc}
    config.columns = [
      :iteration,
      :dates, 
      :dates_with_link,
      :start_date, 
      :finish_date, 
      :number_of_workdays, 
      :focus_factor, 
      :estimated_focus_factor, 
      :project, 
      :status,
    ]
    config.create.columns = [:start_date, :finish_date, :number_of_workdays, :estimated_focus_factor, :project]
    config.update.columns = [:start_date, :finish_date, :number_of_workdays, :estimated_focus_factor, :project]
    config.columns[:start_date].form_ui = :calendar_date_select
    config.columns[:number_of_workdays].options = {:size => 3}
    config.columns[:estimated_focus_factor].options = {:size => 3}
    config.columns[:start_date].options = {:size => 17}
    config.columns[:finish_date].options = {:size => 17}
    config.columns[:estimated_focus_factor].label = "Est. focus factor"
    config.columns[:dates_with_link].label = "Dates"
    config.columns[:number_of_workdays].description = "Leave blank for auto-calculation"
    config.list.label = "&nbsp;"
    config.show.link = false
    config.columns[:iteration].css_class = "big-bold numeric"
    config.columns[:commitments].collapsed = false
    config.list.no_entries_message = "No sprint is defined for this project yet.<br /> Click <em>Create new</em> to add one."
  end

  def show
    do_show
    successful?

    case @record.status
    when "planning" 
      sprint_before = Sprint.before(@record.start_date).by_start_date.last

      if sprint_before && sprint_before.status != 'closed'
        @message = "Sprint planning cannot be done until all sprints before are closed."
        render 'message/index'
      else
        redirect_to project_sprint_planning_path(@record.project, @record)
      end
    when "closed" : redirect_to project_sprint_closed_path(@record.project, @record)
    when "in_course" : redirect_to project_sprint_current_path(@record.project, @record)
    else
      @message = "This page is not implemented yet. Coming soon : )"
      render 'message/index'
    end
  end

  def show_planning
    unless show_planning_authorized?
      @message = "Only Admins and Scrum Masters are allowed to do Sprint planning."
      render :template => "message/index" and return
    end

    do_show
    successful?
    active_scaffold_config.show.label = "Planning #{@record.to_label}"
  end

  def show_current
    raise ActiveScaffold::ActionNotAllowed unless show_current_authorized?
    do_show
    successful?
    @burndown_graph = open_flash_chart_object(600,300, url_for(:action => "burndown_graph_data", :id => params[:id]))
    active_scaffold_config.show.label = "#{@record.to_label} (current)"
  end

  def show_closed
    raise ActiveScaffold::ActionNotAllowed unless show_closed_authorized?
    do_show
    successful?
    @burndown_graph = open_flash_chart_object(600,300, url_for(:action => "burndown_graph_data", :id => params[:id]))
    active_scaffold_config.show.label = "#{@record.to_label} Statistics"
  end

  def finish_planning
    @record = Sprint.find params[:id]

    raise ActiveScaffold::ActionNotAllowed.new unless finish_planning_authorized?

    render_message 'There are no stories defined yet. Please create some.' and return if current_project.stories.empty?

    if @record.commitments.blank?
      render_message "There are no users commited to this sprint yet. Please add someone before continuing." and return
    end

    if @record.factible_stories.blank?
      render_message "No story was added to sprint planning. Please check that you created some commitments and stories are properly estimated." and return
    end

    if @record.factible_stories.map(&:storypoints).include? nil
      render_message 'Some stories lack of storypoints. Please define them before proceeding.' and return
    end

    if @record.factible_stories.map(&:hours_left).include? nil
      render_message 'Some stories\' has no tasks or those are not estimated. Please estimate them before proceeding.' and return
    end

    @record.plannings.destroy_all
    @record.generate_plannings

    redirect_to :action => 'index'
  end

  def day
    params[:id] ||= params[:sprint_id]
    do_show

    date = @record.start_date + params[:day].to_i
    redirect_to project_stats_for_date_path(@record.project, date.to_time.strftime("%Y-%m-%d"))
  end

  def burndown_graph_data
    sprint = Sprint.find params[:id], :include => {:stories => {:tasks => :work_hours}}
    ideal_hours_left_values = sprint.burndown_date_range.map{|d| sprint.ideal_hours_left_for_day d}
    real_hours_left_values = sprint.burndown_date_range.map{|d| sprint.hours_left_for_day d}
    x_labels = sprint.date_range.map{|d| d.strftime('%d') }
    link = "redirect_to_stats_for_day"

    values = [
      {:values => real_hours_left_values, :link => link, :text => "Real"},
      {:values => ideal_hours_left_values, :link => link, :text => "Ideal"}
    ]
    config = {
      :x_labels => x_labels, 
      :y_leyend => "Hours Left", 
      :x_leyend => "#{sprint.start_date.strftime "%B %d"} to #{sprint.finish_date.strftime "%B %d"}"
    }

    chart = graph_data_for values, config

    render :text => chart.to_s
  end
    

  protected

  def column_selection

    # Planning mode /projects/1/sprint/3/planning
    if params[:mode] == 'planning'
      active_scaffold_config.show.columns.exclude active_scaffold_config.show.columns.map(&:name)
      active_scaffold_config.show.columns << [:dates, :estimated_focus_factor]

    # Mini mode /projects/1
    elsif params[:mode] == 'mini'
      active_scaffold_config.list.columns.exclude active_scaffold_config.list.columns.map(&:name)
      active_scaffold_config.list.columns << [:dates, :status]

      %W{new edit delete}.each do |action|
        active_scaffold_config.action_links.delete action
      end

      active_scaffold_config.list.no_entries_message = "No sprint is defined for this project yet.<br /><br /> Click <em>Sprints</em> to start adding them."

    # Normal mode /project/1/sprints
    else
      active_scaffold_config.list.columns.exclude active_scaffold_config.list.columns.map(&:name)
      active_scaffold_config.list.columns << [:iteration, :dates_with_link, :focus_factor, :status]

      active_scaffold_config.action_links << ActiveScaffold::Config::Create.link
      active_scaffold_config.action_links << ActiveScaffold::Config::Update.link
      active_scaffold_config.action_links << ActiveScaffold::Config::Delete.link

      active_scaffold_config.list.no_entries_message = "No sprint is defined for this project yet.<br /> Click <em>Create new</em> to add one."
    end
  end

  def do_new
    do_new_with_project
  end

  def show_respond_to_html
    params[:mode] = @record.status
    case @record.status
    when "planning"
      active_scaffold_config.show.label = "Planning #{@record.to_label}"
      render :action => "show_planning"
    else 
      active_scaffold_config.show.label = @record.to_label
      super
    end
  end

  # This is not part of active_scaffold. It won't delegate to
  # model when true
  def finish_planning_authorized?
    current_user_is_admin_or? :scrum_master
  end

  # This is not part of active_scaffold. It won't delegate to
  # model when true
  def show_closed_authorized?
    current_user_is_admin_or? :scrum_master, :team_member, :product_owner
  end

  # This is not part of active_scaffold. It won't delegate to
  # model when true
  def show_current_authorized?
    current_user_is_admin_or? :scrum_master, :team_member, :product_owner
  end

  # This is not part of active_scaffold. It won't delegate to
  # model when true
  def show_planning_authorized?
    current_user_is_admin_or? :scrum_master
  end

  def show_authorized?
    current_user.projects_to_show.include? current_project
  end

  def create_authorized?
    current_user.admin? || plays_current_user_role?(:scrum_master)
  end

  def delete_authorized?
    current_user.admin? || plays_current_user_role?(:scrum_master)
  end

  def update_authorized?
    current_user.admin? || plays_current_user_role?(:scrum_master)
  end
end

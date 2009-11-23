class ProjectsController < ApplicationController
  active_scaffold do |config|
    config.show.link = false
    config.search.link = false
    config.create.columns = [:name, :description]
    config.update.columns = [:name, :description]
    config.columns[:description].options = {:rows => 5}
    config.list.label = "&nbsp;"
    config.list.no_entries_message = "No projects created yet.<br /> Click <em>Create New</em> to add one."
  end

  def show
    do_show
    successful?
    @focus_factor_graph = open_flash_chart_object(300,150, url_for(:action => "focus_factor_graph_data", :id => params[:id]))
    @team_velocity_graph = open_flash_chart_object(300,150, url_for(:action => "team_velocity_graph_data", :id => params[:id]))
    respond_to_action(:show)
  end

  def team_velocity_graph_data
    project = Project.find params[:id]
    sprints = project.sprints.sort_by(&:start_date)
    values = sprints.map(&:team_velocity)
    x_labels = sprints.map{|s| "#{s.iteration}"}
    x_labels[0] = "Iter. " + x_labels[0].to_s

    chart = graph_data_for [{:values => values, :text => "Real"}], {:x_labels => x_labels, :y_leyend => "Storypoints"}
    render :text => chart.to_s
  end

  def focus_factor_graph_data
    project = Project.find params[:id]
    sprints = project.sprints.sort_by(&:start_date)

    focus_factor_values = sprints.map(&:focus_factor)
    estimated_focus_factor_values = sprints.map(&:estimated_focus_factor)
    x_labels = sprints.map{|s| "#{s.iteration}"}
    x_labels[0] = "Iter. " + x_labels[0].to_s

    chart = graph_data_for [{:values => focus_factor_values, :text => "Real"},
      {:values => estimated_focus_factor_values, :text => "Estimated"}], 
      {:x_labels => x_labels, :y_leyend => "Focus Factor"}

    render :text => chart.to_s
  end

  protected

  def custom_finder_options
    Project.for_user(current_user).proxy_options
  end

  def create_authorized?
    current_user.admin?
  end

  def read_authorized?
    true
  end

  def delete_authorized?
    current_user.admin?
  end

  def update_authorized?
    current_user.admin?
  end
end

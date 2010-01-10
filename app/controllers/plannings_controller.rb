class PlanningsController < ApplicationController
  active_scaffold do |config|
    config.columns = [:story, :name, :original_estimation, :hours_left, :description, :tasks, :sprint, :unexpected]
    config.show.columns = [:description, :tasks]
    config.list.columns = [:name, :hours_left, :unexpected]
    config.create.columns = [:story, :sprint, :unexpected]
    config.show.link = false
    config.search.link = false
    config.create.link.label = "Add unexpected story"
    config.delete.link = false
    config.update.link = false
    config.list.per_page = 30
    config.columns[:name].set_link :show
    config.columns[:story].label = "&nbsp;"
    config.columns[:unexpected].label = "&nbsp;"
    config.create.label = "Unexpected story"
    config.list.sorting = {:id => :desc}
  end

  def new
    do_new
    @record.unexpected = true
    respond_to_action :new
  end

  private

  def show_authorized?
    current_user.projects_to_show.include? current_project
  end

  def create_authorized?
    current_user.admin? || plays_current_user_role?(:scrum_master)
  end

  def update_authorized?
    current_user.admin? || plays_current_user_role?(:scrum_master)
  end

  def delete_authorized?
    current_user.admin? || plays_current_user_role?(:scrum_master)
  end
end

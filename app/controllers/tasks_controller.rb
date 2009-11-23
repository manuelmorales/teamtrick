class TasksController < ApplicationController
  before_filter :column_selection

  active_scaffold do |config|
    config.columns = [:name, :description, :original_estimation, :hours_left, :story, :work_hours]
    config.columns[:description].options = {:rows => 4, :truncate => 15}
    config.list.columns.exclude [:description, :original_estimation, :story, :work_hours]
    config.show.columns.exclude [:name, :description, :original_estimation, :story, :work_hours]
    config.create.columns.exclude [:hours_left]
    config.search.link = false
    config.columns[:name].set_link :show
    config.show.link = false
    config.columns[:original_estimation].options = {:size => 3}
    config.columns[:hours_left].options = {:size => 3}
    config.columns[:name].options = {:size => 29}
    config.columns[:description].options = {:cols => 32, :rows => 4}
    config.list.no_entries_message = "No tasks for this story yet.<br /> Click <em>Create New</em> to add one."
  end

  protected

  def before_update_save record
    record.work_hours.select(&:new_record?).each do |wh|
      wh.old_hours_left = (record.changes["hours_left"] && record.changes["hours_left"].first) || record.hours_left
    end
  end

  def column_selection
    if ['current', 'closed'].include? params[:mode]
      active_scaffold_config.update.columns.exclude [:original_estimation]
    else
      active_scaffold_config.create.columns.exclude [:work_hours]
      active_scaffold_config.update.columns.exclude [:work_hours]
    end
  end

  def show_authorized?
    current_user_is_admin_or?(:product_owner, :scrum_master, :team_member)
  end

  def create_authorized?
    current_user_is_admin_or?(:product_owner, :scrum_master, :team_member)
  end

  def update_authorized?
    current_user_is_admin_or?(:product_owner, :scrum_master, :team_member)
  end

  def delete_authorized?
    current_user_is_admin_or?(:product_owner, :scrum_master, :team_member)
  end
end

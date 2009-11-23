class WorkHoursController < ApplicationController
  active_scaffold do |config|
    config.columns = [:date, :user, :hours, :task]
    config.show.columns.exclude :task
    config.list.columns.exclude :task
    config.columns[:user].form_ui = :select
    config.columns[:date].form_ui = :calendar_date_select
    config.columns[:date].options = {:size => 12}
    config.columns[:hours].options = {:size => 2}
    config.columns[:hours].label = "Worked hours"
    config.search.link = false
    config.create.link = false
    config.update.link = false
    config.delete.link = false
    config.show.link = false
    config.list.no_entries_message = "No work hours for this task yet.<br /> Click <em>Edit</em> to start adding work hours."
  end

  protected

  def before_create_save record
    record.old_hours_left = record.task.hours_left if record.task
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

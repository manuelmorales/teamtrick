class CommitmentsController < ApplicationController
  active_scaffold do |config|
    config.columns = [:user, :level, :sprint]
    config.columns[:user].form_ui = :select
    config.columns[:level].options = {:size => 3}
    config.columns[:level].description = "% of the time this user is going to be commited to this project"
    config.columns[:level].label = "Commitment level"
    config.show.link = false
    config.search.link = false
    config.create.link.label = "Add User"
    config.delete.link.label = "Remove"
  end

  def show_authorized?
    current_user.projects_to_show.include? current_project
  end

  def create_authorized?
    current_user.admin? || plays_current_user_role?(:product_owner, :scrum_master)
  end

  def update_authorized?
    current_user.admin? || plays_current_user_role?(:product_owner, :scrum_master)
  end

  def delete_authorized?
    current_user.admin? || plays_current_user_role?(:product_owner, :scrum_master)
  end
end

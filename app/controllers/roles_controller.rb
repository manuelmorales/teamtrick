class RolesController < ApplicationController
  active_scaffold

  def show_authorized?
    true
  end

  def create_authorized?
    false
  end

  def delete_authorized?
    false
  end

  def update_authorized?
    false
  end
end

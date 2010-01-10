module DutiesHelper
  def options_for_association_conditions(association)
    if association.name == :user
      ['users.disabled = ?', false]
    else
      super
    end
  end

  def user_column r
    link_to(r.user.name, user_path(r.user)) if r.user
  end
end

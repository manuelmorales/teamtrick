module CommitmentsHelper
  def level_column r
    "#{r.level.to_i}% (#{r.available_hours.to_i} hours)"
  end

  def user_column r
    link_to(r.user.name, user_path(r.user)) if r.user
  end

  def options_for_association_conditions(association)
    if association.name == :user

      users_with_role_in_current_project = current_project.duties.map{|c| c.user_id}
      users_with_commitment = @record.sprint.commitments.map(&:user_id)
      users_with_role_without_commitment = users_with_role_in_current_project - users_with_commitment

      ['users.id IN (?)', users_with_role_without_commitment ]
    else
      super
    end
  end
end

module TasksHelper
  def hours_left_column record
    record.hours_left.to_s + "h left"
  end

  def options_for_association_conditions(association)
    if association.name == :user
      ['users.id IN (?)', @record.sprint.commitments.map{|c| c.user_id} ] if @record.sprint
    else
      super
    end
  end
end

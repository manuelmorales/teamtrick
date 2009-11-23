module DutiesHelper
  def options_for_association_conditions(association)
    if association.name == :user
      ['users.disabled = ?', false]
    else
      super
    end
  end
end

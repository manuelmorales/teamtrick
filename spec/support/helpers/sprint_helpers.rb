module SprintHelpers
  def check_all_overlapping_possibilities_for existent_sprint, conflicting_sprint = Sprint.new(sprint_required_values), &block
    raise "the existent sprint should be at least 2 weeks long" if existent_sprint.duration < 14 

    #                 #------------#  (existent)
    #      #----------#               (conflictive)
    conflicting_sprint.start_date = existent_sprint.start_date - 4.weeks
    conflicting_sprint.finish_date = existent_sprint.start_date
    conflicting_sprint.save
    yield conflicting_sprint

    #                 #------------#
    #      #-----------------#
    conflicting_sprint.start_date = existent_sprint.start_date - 2.weeks
    conflicting_sprint.finish_date = existent_sprint.start_date + 1.weeks
    yield conflicting_sprint

    #                 #------------#
    #      #-----------------------#
    conflicting_sprint.start_date = existent_sprint.start_date - 2.weeks
    conflicting_sprint.finish_date = existent_sprint.finish_date
    yield conflicting_sprint

    #                 #------------#
    #      #---------------------------#
    conflicting_sprint.start_date = existent_sprint.start_date - 1.week
    conflicting_sprint.finish_date = existent_sprint.finish_date + 1.week
    yield conflicting_sprint

    #                 #------------#
    #                 #------------#
    conflicting_sprint.start_date = existent_sprint.start_date
    conflicting_sprint.finish_date = existent_sprint.finish_date
    yield conflicting_sprint

    #                 #------------#
    #                 #--------------#
    conflicting_sprint.start_date = existent_sprint.start_date
    conflicting_sprint.finish_date = existent_sprint.finish_date + 1.week
    yield conflicting_sprint

    #                 #------------#
    #                    #---------------#
    conflicting_sprint.start_date = existent_sprint.start_date + 1.week
    conflicting_sprint.finish_date = existent_sprint.finish_date + 1.week
    yield conflicting_sprint

    #                 #------------#
    #                              #---------------#
    conflicting_sprint.start_date = existent_sprint.finish_date
    conflicting_sprint.finish_date = existent_sprint.finish_date + 2.weeks
    yield conflicting_sprint
  end
end

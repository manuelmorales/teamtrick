module WorkHoursHelper
  def hours_column r
    h "#{r.hours} hours"
  end

  def user_column r
    link_to(r.user.name, user_path(r.user)) if r.user
  end

  def task_with_story_column r
    link_to "#{r.story.name}, #{r.task.name}", project_story_path(current_project, r.story)
  end
end

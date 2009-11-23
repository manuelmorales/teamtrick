module WorkHoursHelper
  def hours_column r
    h "#{r.hours} hours"
  end

  def user_column r
    link_to(r.user.name, user_path(r.user)) if r.user
  end
end

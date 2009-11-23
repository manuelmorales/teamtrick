module SprintsHelper
  def dates_column r
    out =  "#{r.start_date.to_formatted_s :short} - "
    out << "#{r.finish_date.to_formatted_s :short} "
    out << "(#{r.number_of_workdays} workdays)"
    out
  end

  def status_column r
    if r.status == "planning"
      "Pending"
    else
      r.status.humanize
    end
  end

  def dates_with_link_column r
    if r.status == "planning" && !show_planning_authorized?
      dates_column r
    else
      link_to dates_column(r), project_sprint_path(r.project, r.id)
    end
  end

  def focus_factor_column r
    if r.focus_factor
      "#{r.focus_factor.round(2)}/#{r.estimated_focus_factor} (real/estim)"
    else
      "#{r.estimated_focus_factor} estim"
    end
  end
end

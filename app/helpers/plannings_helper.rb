module PlanningsHelper
  def hours_left_column r
    if r.hours_left
      h "#{r.hours_left.to_s}h"
    else
      "Not estimated yet."
    end
  end

  def original_estimation_column r
    h "#{r.original_estimation.to_s}h"
  end

  def unexpected_column r
    r.unexpected ? "Unexpected" : "&nbsp;"
  end
end

# Tasks are the minimal work units an Story is 
# split into.
class Task < ActiveRecord::Base
  validates_presence_of :story
  validates_presence_of :name
  validates_presence_of :original_estimation
  has_many :work_hours, :dependent => :destroy
  belongs_to :story

  # sets hours_left to original_estimation 
  # if it hasn't been set
  after_validation lambda{|t| t.hours_left ||= t.original_estimation; true}

  # Simply returns its Story's project.
  def project
    story.project
  end

  def hours_left_for_day d
    # Using named_scopes like this:
    # work_hours = WorkHour.with_task(self).after(d).by_date
    # forces database usage. It is faster to do eager 
    # loading and sort them like this
    work_hours = self.work_hours.reject{|wh| wh.date < d}
    work_hours = work_hours.sort{|a,b| a.date == b.date ? a.created_at <=> b.created_at : a.date <=> b.date}
    if work_hours.empty?
      hours_left
    else
      work_hours[0].old_hours_left
    end
  end
end

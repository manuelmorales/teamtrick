# Each Sprint object represents a real Sprint.
# With its dates, Stories, estimated Focus Factor,
# etc. 
class Sprint < ActiveRecord::Base
  validates_presence_of :start_date
  validates_presence_of :finish_date
  validates_presence_of :estimated_focus_factor
  validates_presence_of :project
  validates_numericality_of :number_of_workdays, 
    :allow_nil => true,
    :only_integer => true,
    :greater_than => 0

  belongs_to :project
  has_many :plannings
  has_many :stories, :through => :plannings
  has_many :commitments

  named_scope :with_project, lambda{|p| {:conditions => {:project_id => p.id}}}
  named_scope :before, lambda{|date| {:conditions => ['finish_date < ?', date]}}
  named_scope :by_start_date, :order => "start_date ASC"

  # Add errors to the ActiveRecord instance in case that
  # start_date and finish_date are not valid. It will check
  # that:
  #
  # * Start date is earlier than finish date.
  # * It can't overlap an existing Sprint.
  #
  # For more on custom validations see The Rails Way page
  # 268.
  def validate
    if start_date && finish_date && project
      if start_date > finish_date
        errors.add :start_date, "should be earlier than finish date"
      end

      # We check the id to ensure to avoid checking the sprint against itself
      # If the sprint is a new record, we check with id != 0 because we cannot use id != nil

      # Checking that start_date and finish_date aren't inside an existent sprint
      {:start_date => start_date, :finish_date => finish_date}.each do |key, date|
        if Sprint.find( :first, 
                       :conditions => ["start_date <= ? AND finish_date >= ? AND id != ? AND project_id == ?", date, date, id || 0, project.id || 0]
                      )
          errors.add key, "overlaps an existing sprint"
        end
      end

      # Checking that start_date and finish_date aren't surrounding an existent sprint
      if Sprint.find( :first, :conditions => ["start_date >= ? AND finish_date <= ? AND id != ? AND project_id == ?", start_date, finish_date, id || 0, project.id || 0])
        errors.add :start_date, "surrounds an existing sprint"
      end

      if start_date == finish_date
        errors.add :start_date, "should be earlier than finish date"
      end
    end
  end

  # Returns all the WorkHours created during this Sprint.
  def work_hours
    wh = WorkHour.with_project(project).with_date_between(start_date..finish_date)
  end

  # Returns the total number of hours that team member have worked
  # on this Sprint.
  def work_hours_sum
    work_hours.map{|w| w.hours}.sum
  end

  # Returns all the Stories that has been worked on during this 
  # Sprint.
  def worked_on_stories
    # IMPROVE: improve performance removing &:task and &:story
    work_hours.map(&:task).compact.map(&:story).compact.uniq
  end

  # Returns the number of workdays contained by this Sprint.
  # Understanding for workday Monday to Friday.
  def number_of_workdays
    super || (start_date && finish_date && (start_date..finish_date).reject{|wd| wd.holidays? }.length)
  end

  # Returns the number of available human hours of work taking
  # care of workdays and users' commitments.
  def available_hours
    # IMPROVE: change available_hours_per_week / 5 to available_hours_per_workday
    commitments.map{|c| c.level / 100 * c.user.available_hours_per_week / 5 * number_of_workdays}.sum.to_i
  end

  # Calculates and returns the Focus Factor for this Sprint.
  # It is done dividing the available hours of human work
  # by the sum of WorkHours.
  def focus_factor
    if status == "closed"
      result = available_hours.to_f / work_hours_sum 
      result.nan? ? 0.0 : result
    end
  end

  # Returns "closed", "planning" or "in_course"
  # depending on the status of the Sprint. It will
  # return "planning" even if we've reached start_date
  # but the Sprint has no Plannings yet.
  def status
    today = Date.today
    if !start_date or !finish_date
      "planning"
    elsif today > finish_date
      "closed"
    elsif today < start_date or plannings.empty?
      "planning"
    elsif (start_date..finish_date).include? today
      "in_course"
    else
      raise Exception.new, "Wrong date range for sprint #{inspect}"
    end
  end

  # Returns the duration of the Sprint in days.
  def duration
    (finish_date - start_date).to_i
  end

  # Returns the date when the first Planning was created.
  def planning_date
    plannings.sort_by{|p| p.created_at}.first.created_at.to_date
  end

  # Returns all the Stories that has to be done on this Sprint but wasn't
  # added on planning_date but later.
  def unplanned_stories
    plannings.select{|p| p.created_at.to_date > planning_date}.map{|p| p.story }
  end

  # Returns the array of Stories that it is estimated that can be done 
  # on that Sprint, taking them from the top of the Backlog.
  def factible_stories
    uncompleted_stories = Story.with_project(project).uncompleted.by_importance
    list = []
    hours = 0

    uncompleted_stories.each do |s|
      if hours + s.hours_left.to_i <= available_hours
        list << s
        hours += s.hours_left.to_i
      else
        break
      end
    end

    list
  end

  # Returns the sum of storypoints of finished Stories
  # during that Sprint
  def team_velocity
    plannings.map{|p| p.story.completed? ? p.story.storypoints : 0}.sum if status == 'closed'
  end

  # Returns the iteration number for this Sprint
  # The first Sprint will be iteration 1, 
  # the next, iteration 2, etc.
  def iteration
    Sprint.with_project(project).before(start_date).count + 1
  end

  # Will generate a Planning for each factible Story
  # for this Sprint
  def generate_plannings
    factible_stories.reverse.each do |s|
      Planning.create :story => s, :sprint => self
    end
  end

  # Will return the sum of its Plannings' original estimations
  # This is used to calculate ideal Burndown
  def ideal_hours_left
    plannings.map(&:original_estimation).compact.sum
  end

  # Will return the estimated Sprint's hours left to 
  # generate the ideal Burndown
  def ideal_hours_left_for_day d
    if d < start_date 
      ideal_hours_left.to_f
    elsif d > finish_date
      0
    else 
      ideal_hours_left.to_f / (duration + 1) * (finish_date - d + 1)
    end
  end

  def hours_left_for_day d
    d > Date.today + 1 ? nil : stories.map{|s| s.tasks.map{|t| t.hours_left_for_day(d)}}.flatten.sum
  end

  # Will return the Date range between
  # start date an finish date
  def date_range
    start_date..finish_date
  end

  # Will return the Date range between
  # start date an finish date plus one day
  def burndown_date_range
    start_date..(finish_date + 1)
  end

  def to_label
    "Sprint " + iteration.to_s
  end

  def name
    to_label
  end
end

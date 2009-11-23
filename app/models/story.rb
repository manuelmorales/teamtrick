# Stories are new features to be implemented into the
# project. They are split into Tasks before that.
class Story < ActiveRecord::Base
  has_many :tasks, :dependent => :destroy
  has_many :plannings, :dependent => :destroy
  belongs_to :project
  validates_presence_of :project
  validates_presence_of :name
  validates_presence_of :importance
  validates_numericality_of :importance

  named_scope :with_project, lambda{|p| {:conditions => {:project_id => p.id}} }
  named_scope :by_importance, :order => "importance DESC"

  named_scope :uncompleted, 
    :conditions => 'ID IN (SELECT s.id 
                     FROM stories s
                    WHERE NOT EXISTS (SELECT 1 
                                      FROM tasks t
                                      WHERE s.id = t.story_id)
                    UNION
                    SELECT story_id
                     FROM tasks
                    GROUP BY story_id
                    HAVING (SUM(hours_left) > 0))'

  named_scope :completed, 
    :joins=> :tasks,
    :group => "tasks.story_id", 
    :select=>'stories.*',
    :having => "SUM(tasks.hours_left) = 0"

  # Sets importance to the maximum by default
  def after_initialize
    return unless new_record?
    self.importance ||= Story.maximum(:importance).to_i + 1
  end

  # Returns the sum of the hours left for each Task of
  # this Story
  def hours_left
    self.tasks.empty? ? nil : self.tasks.map(&:hours_left).sum
  end

  # Returns true if there are no hours_left to 
  # finish this Story.
  def completed?
    hours_left == 0
  end

  # Returns the original estimation for this Story based
  # on its Tasks' original_estimation. If it has no 
  # Tasks yet, it will return temporary_estimation.
  def estimation
    self.tasks.map(&:original_estimation).compact.sum
  end

  # Returns the work hours of all Tasks of this Story
  def work_hours
    self.tasks.map(&:work_hours).flatten
  end

  # Changes the importance of the rest of the stories
  # to make room for the new one
  def before_save
    if self.changes["importance"] and self.valid?
      initial, final = self.changes["importance"]
      initial ||= Story.maximum(:importance).to_i + 1

      if initial < final
        self.class.update_all(
          ["importance = importance - 1"], 
          ['project_id = ? AND importance > ? AND importance <= ?', project.id, initial, final]
        )
      else
        self.class.update_all(
          ["importance = importance + 1"], 
          ['project_id = ? AND importance < ? AND importance >= ?', project.id, initial, final]
        )
      end
    else
      true
    end
  end

  def importance_authorized_for_update?
    current_user.admin? || [Role.scrum_master, Role.product_owner].include?(current_user.role_for_project(project))
  end
end

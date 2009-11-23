# The Commitment class defines the relationship
# between Users and Sprints. It defines the percentage
# of its time that an User is going to work on that
# Sprint.
#
# This is useful for Users that are split between two 
# projects. This can also be useful to specify that a
# certain user is going to stay one week away.

class Commitment < ActiveRecord::Base
  validates_presence_of :level
  validates_presence_of :user
  validates_presence_of :sprint
  validates_numericality_of :level, 
    :less_than_or_equal_to => 100, 
    :greater_than_or_equal_to => 0
  validates_uniqueness_of :user_id, 
    :scope => [:sprint_id],
    :message => "is already commited to this sprint"
  belongs_to :user
  belongs_to :sprint

  def name
    user.name
  end

  def available_hours
    user.available_hours_per_week.to_f / 5 * sprint.number_of_workdays * level / 100.0 rescue nil
  end

  def after_initialize 
    return unless new_record?
    self.level ||= 100
  end
end

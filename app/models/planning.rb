# The Planning class establishes a relationship 
# between a Story and a certain Sprint.
# It defines which Stories the team has 
# committed to finish on that Sprint.
class Planning < ActiveRecord::Base
  validates_presence_of :story
  validates_presence_of :sprint
  belongs_to :story
  belongs_to :sprint
  before_save :update_original_estimation

  delegate :name, :hours_left, :description, :tasks, :to => :story

  # Returns the creation date of that Planning
  def date
    created_at.to_date
  end

  # Stores the estimation of that Story into the
  # original estimation attribute. This is done 
  # on before_save to keep track of how many hours 
  # the team has committed to on that Sprint.
  def update_original_estimation
    self.original_estimation = story.hours_left
  end

  # Sets unexpected to false on initialize
  def after_initialize
    return unless new_record?
    self.unexpected ||= false
  end
end

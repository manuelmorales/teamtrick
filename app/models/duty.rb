# The Duty class is used to stablish the relationship
# between an User and a Project. It also defines
# which Role the user will play for that project.
class Duty < ActiveRecord::Base
  belongs_to :user
  belongs_to :project
  belongs_to :role
  validates_presence_of :user
  validates_presence_of :project
  validates_presence_of :role
  validates_uniqueness_of :user_id, 
    :scope => [ :project_id], 
    :message => "cannot be assigned twice to the same project"
  validates_uniqueness_of :role_id, 
    :scope => [ :project_id],
    :if => Proc.new{|d| d.role && d.role.unique?},
    :message => "Scrum Master and Product Owner cannot appear twice on the same project"

  def name
    role.name
  end
end

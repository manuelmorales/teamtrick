# Represents a real Project. This will let 
# this application to be able to track several
# projects.
class Project < ActiveRecord::Base
  validates_presence_of :name
  has_many :duties
  has_many :users, :through => :duties
  has_many :roles, :through => :duties
  has_many :stories, :order => "importance DESC"
  has_many :sprints

  named_scope :for_user, lambda{|u| u.admin? ? {} : {:joins => :duties, :conditions => ['duties.user_id = ?', u.id]}}

  def authorized_for_read?
    if current_user && existing_record_check?
      current_user.admin? || current_user.projects.include?(self)
    else
      true
    end
  end
end

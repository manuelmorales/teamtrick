# Indicates the Role that an User plays (Scrum Master, 
# Product Owner, etc.) for that Project.
# It is used to calculate User permissions.

class Role < ActiveRecord::Base
  validates_presence_of :permalink
  has_many :duties
  has_many :projects, :through => :duties
  has_many :users, :through => :duties

  # Returns an array of permalinks that object 
  # instances can have. The permalink defines which
  # is the exact Role that the User plays.
  def self.possible_permalinks
    %w{scrum-master team-member product-owner guest}
  end

  validates_inclusion_of :permalink,
    :in => Role.possible_permalinks,
    :message => "Invalid permalink.",
    :allow_nil => false

  # Returns the Team Member Role
  def self.team_member
    Role.find_by_permalink 'team_member'
  end

  # Returns the Scrum Master Role
  def self.scrum_master
    Role.find_by_permalink 'scrum_master'
  end

  # Returns the Product Owner Role
  def self.product_owner
    Role.find_by_permalink 'product_owner'
  end
end

require 'digest/sha1'

# The common User model.
class User < ActiveRecord::Base
  has_many :work_hours
  has_many :duties, :extend => FindByAssociatedExtension
  has_many :projects, :through => :duties
  has_many :roles, :through => :duties, :extend => FindByAssociatedExtension
  has_many :commitments

  named_scope :enabled, :conditions => {:disabled => false}

  # FIXME express this as a named scope
  # named_scope :not_present_in, lambda{|project| {:joins => {:duties => :project}, :conditions => ['project_id != ?', project.id]}}

  # Virtual attribute for the unencrypted password
  attr_accessor :password

  validates_presence_of     :login, :email, :real_name
  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?
  validates_length_of       :password, :within => 4..40, :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?
  validates_length_of       :login,    :within => 3..40
  validates_length_of       :email,    :within => 3..100
  validates_uniqueness_of   :login, :email, :case_sensitive => false
  before_save :encrypt_password
  before_save :destroy_all_duties, :if => :disabled

  validates_numericality_of :available_hours_per_week, :positive => true, :greater_than_or_equal_to => 0

  attr_accessible :login, :password, :password_confirmation, :real_name, :email, :available_hours_per_week, :disabled

  alias_attribute :name, :real_name

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(login, password)
    u = find_by_login(login) # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    self.remember_token_expires_at = 2.weeks.from_now.utc
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save(false)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end

  def projects_to_show
    Project.for_user(self)
  end

  def authorized_for_update?
    current_user.admin? || current_user == self
  end

  def disabled_authorized_for_update?
    current_user != self
  end

  def admin_authorized_for_update?
    current_user != self
  end

  def authorized_for_destroy?
    current_user.admin? and current_user != self and !self.disabled?
  end

  def random_password
    Base64.encode64(Digest::SHA1.digest("#{rand(1<<64)}/#{Time.now.to_f}/#{Process.pid}/#{self.login}"))[0..7]
  end

  def role_for_project p
    roles.with_project(p).first
  end

  def duty_for_project p
    duties.with_project(p).first
  end

  protected
    # before filter
    def encrypt_password
      return if password.blank?
      self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
      self.crypted_password = encrypt(password)
    end

    def password_required?
      crypted_password.blank? || !password.blank?
    end

    def destroy_all_duties
      duties.each(&:destroy)
    end
end

require 'digest/sha1'

class User < ActiveRecord::Base

  acts_as_authorization_subject

  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken

  has_and_belongs_to_many :roles
  belongs_to :region

  validates_presence_of     :login,:name,:email
  validates_length_of       :login,    :within => 2..20
  validates_uniqueness_of   :login
  validates_format_of       :login,    :with => Authentication.login_regex, :message => "格式输入不正确"

  # validates_format_of       :name,     :with => Authentication.name_regex,  :message => Authentication.bad_name_message, :allow_nil => true
  validates_length_of       :name,     :maximum => 45

  validates_length_of       :email,    :within => 6..45 #r@a.wk
  # validates_uniqueness_of   :email
  validates_format_of       :email,    :with => Authentication.email_regex, :message => "格式输入不正确"

  validates_length_of :password, :within => 6..40, :if => :password_required?
  validates_presence_of :password, :if => :password_required?
  validates_presence_of :password_confirmation, :if => :password_required?
  validate :check_old_password, :if => :old_password_required?

  # HACK HACK HACK -- how to do attr_accessible from here?
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.

  cattr_accessor :current_user
  attr_accessor :old_password
  attr_accessible :login, :email, :name, :password, :password_confirmation, :old_password, :region_id, :role_ids, :mobile, :phone

  named_scope :include_admin, lambda { |boolean|
    if boolean
    else
      {:include=>:roles,:conditions=>["roles.name != 'admin'"]}
    end
  }

  named_scope :in_region, lambda { |region_id|
    {:conditions=>["users.region_id in (?)",region_id]}
  }

  named_scope :in_role, lambda { |role_id|
    {:include=>:roles,:conditions=>["roles.id in (?)",role_id]}
  }

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  #
  # uff.  this is really an authorization, not authentication routine.
  # We really need a Dispatch Chain here or something.
  # This will also let us return a human error message.
  #
  def self.authenticate(login, password)
    return nil if login.blank? || password.blank?
    u = find_by_login(login.downcase) # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  def password_required?
    !self.password.nil?
  end

  def old_password_required?
    !self.old_password.nil?
  end

  def login=(value)
    write_attribute :login, (value ? value.downcase : nil)
  end

  def email=(value)
    write_attribute :email, (value ? value.downcase : nil)
  end

  def role_names(join="&")
    arr = []
    self.roles.each do |li|
      arr << "#{li.full_name}"
    end
    arr.join(join)
  end

protected

  def check_old_password
    errors.add(:old_password, "输入错误") if !User.authenticate(self.login, self.old_password)
  end

end

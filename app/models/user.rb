require 'digest/sha1'

class User < ActiveRecord::Base

  acts_as_authorization_subject

  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken

  validates_presence_of     :login
  validates_length_of       :login,    :within => 3..20
  validates_uniqueness_of   :login
  validates_format_of       :login,    :with => Authentication.login_regex, :message => "格式输入不正确"

  validates_presence_of     :name
  # validates_format_of       :name,     :with => Authentication.name_regex,  :message => Authentication.bad_name_message, :allow_nil => true
  validates_length_of       :name,     :maximum => 45

  validates_presence_of     :email
  validates_length_of       :email,    :within => 6..45 #r@a.wk
  validates_uniqueness_of   :email
  validates_format_of       :email,    :with => Authentication.email_regex, :message => "格式输入不正确"

  validates_presence_of :password
  validates_presence_of :password_confirmation
  validates_length_of :password, :within => 6..40
  validate :check_password

  has_and_belongs_to_many :roles

  # HACK HACK HACK -- how to do attr_accessible from here?
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessor :old_password
  attr_accessible :login, :email, :name, :password, :password_confirmation, :old_password



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
  
  def check_password
    errors.add(:old_password, "输入错误") if (!User.authenticate(self.login, self.old_password) && !self.old_password.blank?)
  end

end

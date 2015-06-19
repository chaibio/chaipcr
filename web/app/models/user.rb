class User < ActiveRecord::Base
  has_secure_password
  has_many :user_tokens
  
  validates :email, presence: true, uniqueness: true, format: { with: /\A(|(([A-Za-z0-9]+_+)|([A-Za-z0-9]+\-+)|([A-Za-z0-9]+\.+)|([A-Za-z0-9]+\++))*[A-Za-z0-9]+@((\w+\-+)|(\w+\.))*\w{1,63}\.[a-zA-Z]{2,6})\z/i }
  validates :password, length:{minimum:4}, confirmation: true, on: :create
  
  ROLE_ADMIN    = "admin"
  ROLE_USER     = "user"

  before_create do |user|
    user.role = ROLE_USER if user.role.nil?
  end
        
  def self.empty?
    self.count == 0
  end
  
  def admin?
    self.role == ROLE_ADMIN
  end
  
  def role=(value)
    value = (!value.blank?)? value.strip.downcase : nil
    write_attribute(:role, value)
  end
  
  def email=(value)
    if !value.blank?
      write_attribute(:email, value.strip.downcase)
    end
  end
  
  def token
    if @user_token == nil
      @user_token = UserToken.create(:user=>self)
    end
    return (@user_token != nil)? @user_token.token : nil
  end
end

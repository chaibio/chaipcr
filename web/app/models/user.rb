class User < ActiveRecord::Base
  has_secure_password
  has_many :user_tokens
  
  validates :email, presence: true, uniqueness: true, format: { with: /\A(|(([A-Za-z0-9]+_+)|([A-Za-z0-9]+\-+)|([A-Za-z0-9]+\.+)|([A-Za-z0-9]+\++))*[A-Za-z0-9]+@((\w+\-+)|(\w+\.))*\w{1,63}\.[a-zA-Z]{2,6})\z/i }
  validates :password, length:{minimum:4}, confirmation: true, on: :create
  
  ROLE_DEFAULT  = 0
  ROLE_ADMIN    = 1

  def admin?
    role == ROLE_ADMIN
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

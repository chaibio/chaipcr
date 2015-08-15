class UsersController < ApplicationController
  before_filter :ensure_authenticated_user, :except => :create

  respond_to :json
  
  resource_description { 
    formats ['json']
    description "all the actions only allowed if admin user logged in, otherwise response code 401 will be returned"
  }
  
  def_param_group :user do
    param :user, Hash, :desc => "User Info", :required => true do
      param :name, String, :desc => "User Name", :required => true
      param :email, String, :desc => "User Email", :required => true
      param :password, String, :desc => "User Password", :required => true, :action_aware => true
      param :password_confirmation, String, :desc => "User Password Confirmation", :required => true, :action_aware => true
      param :role, ["admin", "user"], :desc => "User Role", :required => false
     end
  end
  
  api :GET, "/users", "List all the users"
  example "[{'user':{'id':1,'name':'admin','email':'admin@admin.com','role':'admin'}}]"
  def index
    @users = User.all
    respond_to do |format|
      format.json { render "index", :status => :ok }
    end
  end
  
  api :POST, "/users", "Create an user"
  param_group :user
  example "[{'user':{'id':1,'name':'test','email':'test@test.com','role':'user'}}]"
  def create
    if (User.empty? && params[:user][:role] == "admin") || ensure_authenticated_user
      @user = User.new(user_params)
      ret = @user.save
      respond_to do |format|
        format.json { render "show", :status => (ret)? :ok : :unprocessable_entity}
      end
    end
  end

  api :PUT, "/users/:id", "Update an user"
  param_group :user
  example "[{'user':{'id':1,'name':'test','email':'test@test.com','role':'user'}}]"
  def update
    @user = User.find_by_id(params[:id])
    ret  = @user.update_attributes(user_params)
    respond_to do |format|
      format.json { render "show", :status => (ret)? :ok : :unprocessable_entity}
    end
  end
  
  api :DELETE, "/users/:id", "Destroy an user"
  def destroy
    @user = User.find_by_id(params[:id])
    if @user == current_user
      ret = false
      @user.errors.add(:base, "cannot destroy yourself")
    else
      ret = @user.destroy
    end
    respond_to do |format|
      format.json { render "destroy", :status => (ret)? :ok : :unprocessable_entity}
    end
  end
  
  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :role)
  end
  
  def authorized?
    current_user.admin?
  end
end
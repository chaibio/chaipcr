class UsersController < ApplicationController
#  before_filter :admin_required

  respond_to :json
  
  resource_description { 
    formats ['json']
  }
  
  def_param_group :user do
    param :user, Hash, :desc => "User Info", :required => true do
      param :email, String, :desc => "User Email", :required => true
    end
  end
  
  def index
    @users = User.all
    respond_to do |format|
      format.json { render "index", :status => :ok }
    end
  end
  
  def create
    @user = User.new(user_params)
    ret = @user.save
    respond_to do |format|
      format.json { render "show", :status => (ret)? :ok : :unprocessable_entity}
    end
  end

  def update
    @user = User.find_by_id(params[:id])
    ret  = @user.update_attributes(user_params)
    respond_to do |format|
      format.json { render "show", :status => (ret)? :ok : :unprocessable_entity}
    end
  end
  
  def destroy
    @user = User.find_by_id(params[:id])
    ret = @user.destroy
    respond_to do |format|
      format.json { render "destroy", :status => (ret)? :ok : :unprocessable_entity}
    end
  end
  
  private

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation, :role)
  end
end
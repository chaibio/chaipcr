class SessionsController < ApplicationController
  respond_to :json
  
  resource_description { 
    formats ['json']
  }
  
  api :POST, "/login", "Login"
  param :email, String, :desc => "Email", :required => true
  param :password, String, :desc => "Password", :required => true
  error :code => 401, :desc => "{'errors':'The email and password entered do not match'}"
  example "{'authentication_token':'adfadfdfadf'}"
  description "cookie will be set with the authentication token, the token will expire in a day"
  def create
    user = User.where("email=?", params[:email]).first
    if user && user.authenticate(params[:password])
      cookies.permanent[:authentication_token] = user.token
      render json: {authentication_token: user.token}, status: 201
    else
      render json: {errors: "The email and password entered do not match"}, status: 401
    end
  end
  
  api :POST, "/logout", "Logout"
  def destroy
    user_token = UserToken.where(access_token: UserToken.digest(token)).first
    if user_token
      user_token.destroy
    end
    render json: {}, status: 200
  end
end
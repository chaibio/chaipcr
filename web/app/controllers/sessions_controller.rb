class SessionsController < ApplicationController
  def create
    user = User.where("email=?", params[:email]).first
    if user && user.authenticate(params[:password])
      cookies.permanent[:authentication_token] = user.token
      render json: {authentication_token: user.token}, status: 201
    else
      render json: {errors: "The email and password entered do not match"}, status: 401
    end
  end
  
  def destroy
    user_token = UserToken.where(access_token: UserToken.digest(token)).first
    if user_token
      user_token.destroy
    end
    render json: {}, status: 200
  end
end
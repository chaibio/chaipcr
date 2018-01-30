#
# Chai PCR - Software platform for Open qPCR and Chai's Real-Time PCR instruments.
# For more information visit http://www.chaibio.com
#
# Copyright 2016 Chai Biotechnologies Inc. <info@chaibio.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
class SessionsController < ApplicationController
  respond_to :json
	include Swagger::Blocks

  resource_description {
    formats ['json']
  }

	swagger_path '/login' do
		operation :post do
			key :summary, 'Login'
			key :description, 'Logs in the user'
			key :produces, [
				'application/json',
			]
			key :tags, [
				'Sessions'
			]
			parameter do
				key :name, :login_params
				key :in, :body
				key :description, 'Login detals'
				key :required, true
				schema do
					key :'$ref', :login_params
				end
			end
			response 201 do
				key :description, 'User is logged in to the application'
			end
		end
		operation :get do
			key :summary, 'Login page'
			key :description, 'Show this page when there are users in the database and user is not logged in'
			key :produces, [
				'application/html',
			]
			key :tags, [
				'Main'
			]
			response 200 do
				key :description, 'Login Page is returned'
			end
		end
	end



  api :POST, "/login", "Login"
  param :email, String, :desc => "Email", :required => true
  param :password, String, :desc => "Password", :required => true
  error :code => 401, :desc => "{'errors':'The email and password entered do not match'}"
  example "{'user_id':4, 'authentication_token':'adfadfdfadf'}"
  description "cookie will be set with the authentication token, the token will expire in a day"
  def create
    user = User.where("email=?", params[:email]).first
    if user && user.authenticate(params[:password])
      cookies.permanent[:authentication_token] = user.token
      render json: {user_id: user.id, authentication_token: user.token}, status: 201
    else
      render json: {errors: "The email and password entered do not match"}, status: 401
    end
  end

	swagger_path '/logout' do
		operation :post do
			key :summary, 'Logout'
			key :description, 'Logout of the application and redirected to the login page'
			key :produces, [
				'application/json',
			]
			key :tags, [
				'Sessions'
			]
			response 200 do
				key :description, 'User is logged out'
			end
		end
	end

  api :POST, "/logout", "Logout"
  def destroy
    user_token = UserToken.where(access_token: UserToken.digest(authentication_token)).first
    if user_token
      user_token.destroy
    end
    render json: {}, status: 200
  end
end

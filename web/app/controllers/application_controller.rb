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
class ApplicationController < ActionController::Base
  helper_method :authentication_token, :current_user
 
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session

  CLOUD_SERVER = "http://cloudops.chaibio.com"
 
  protected

  def kill_process(process_name)
    processes = `ps -ef | grep #{process_name}`
    logger.info(processes)
    processes.lines.each do |process|
      nodes = process.split(/\W+/)
      cmd = "kill -9 #{nodes[1]}"
      logger.info(cmd)
      system(cmd)
    end
  end
  
  def logged_in?
    current_user != nil
  end

  # Renders a 401 status code if the current user is not authorized
  def ensure_authenticated_user
    if logged_in? && authorized?
      return true
    else
      if User.empty? && !Device.serialized?
        User.create_factory_user!
      end
      respond_to do |format|
        format.json { render json: {errors: (logged_in?)? "unauthorized" : (User.empty?)? "sign up" : "login in"}, status: :unauthorized }
        format.html { redirect_to (logged_in?)? login_path : (User.empty?)? welcome_path : login_path }
      end
      return false
    end
  end

  def authorized?
    return true
  end

  # Returns the active user associated with the access token if available
  def current_user
    if @current_user == nil
      user_token = UserToken.active.where(access_token: UserToken.digest(authentication_token)).first
      if user_token
        @current_user = user_token.user
        if user_token.about_to_expire
          user_token.reset_expiry_date!
        end
      end
    end
    return @current_user
  end

  # Parses the access token from the header
  def authentication_token
    if cookies[:authentication_token] != nil
      cookies[:authentication_token]
    else
      bearer = request.headers["HTTP_AUTHORIZATION"]

      # allows our tests to pass
      bearer ||= request.headers["rack.session"].try(:[], 'Authorization')

      if bearer.present?
        bearer.split.last
      else
        nil
      end
    end
  end

  def experiment_definition_editable_check
    get_experiment
    if @experiment == nil || !@experiment.editable?
      render json: {errors: "The experiment is not editable"}, status: :unprocessable_entity
      return false
    else
      return true
    end
  end

  def well_layout_editable_check
    @experiment = Experiment.includes(:well_layout).find_by_id(params[:experiment_id]) if @experiment.nil? && !params[:experiment_id].nil?
    if @experiment
      well_layout = @experiment.well_layout
    end
    if !well_layout.is_a? WellLayout
      render json: {errors: "The well layout doesn't exist"}, status: :unprocessable_entity
      return false
    elsif !well_layout.editable?
      render json: {errors: "The well layout is not editable"}, status: :unprocessable_entity
      return false
    else
      return true
    end
  end
  
  def allow_cors
    headers["Access-Control-Allow-Origin"] = "*"
    headers["Access-Control-Allow-Methods"] = "GET,PUT,POST,OPTIONS"
    headers["Access-Control-Allow-Headers"] = "*"
    headers["Access-Control-Max-Age"] = "1728000"
    headers["Access-Control-Allow-Credentials"] = "true"
  end
end

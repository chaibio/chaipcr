require 'rserve'

class MainController < ApplicationController
  api :GET, "/", "Home page"
  def index
    if !logged_in?
      if User.empty?
        redirect_to welcome_path
      else
        redirect_to login_path
      end
    end
  end
  
  api :GET, "/welcome", "Show this page when there is no user in the database"
  def welcome
    render "main/index"
  end
  
  api :GET, "/login", "Show this page when there are users in the database and user is not logged in"
  def login
    render "main/index"
  end
  
  def rtest
    connection = Rserve::Connection.new
    x = connection.eval("R.version.string")
    render :text => x.as_string
  end
end
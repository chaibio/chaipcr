require 'rserve'

class MainController < ApplicationController

  before_filter :ensure_authenticated_user, :only => :index

  api :GET, "/", "Home page"
  def index

  end

  api :GET, "/welcome", "Show this page when there is no user in the database"
  def welcome
    if User.empty?
      render :welcome, layout: false
    else
      redirect_to login_path
    end
  end

  api :GET, "/login", "Show this page when there are users in the database and user is not logged in"
  def login
    if !User.empty?
      render :login, layout: false
    else
      redirect_to welcome_path
    end
  end

end
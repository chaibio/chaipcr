require 'rserve'

class MainController < ApplicationController
  api :GET, "/", "Home page"
  def index
  end

  def angular
    render layout: false
  end
  
  def rtest
    connection = Rserve::Connection.new
    x = connection.eval("R.version.string")
    render :text => x.as_string
  end
end
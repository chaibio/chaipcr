class MainController < ApplicationController
  api :GET, "/", "Home page"
  def index
  end
end
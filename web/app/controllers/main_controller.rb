class MainController < ApplicationController
  api :GET, "/", "Home page"
  def index
  end

  def angular
    render layout: false
  end
end
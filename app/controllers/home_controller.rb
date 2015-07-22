class HomeController < ApplicationController
  def index
    if current_user && current_user.admin
      redirect_to backends_path
    end
  end
end

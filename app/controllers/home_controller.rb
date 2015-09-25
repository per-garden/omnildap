class HomeController < ApplicationController
  def index
    if current_user && current_user.admin
      redirect_to admin_backends_path
    end
  end
end

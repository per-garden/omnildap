class BackendsController < ApplicationController
  before_filter :require_admin

  def index
    @backends = Backend.all
  end

  def show
    @backend = Backend.find(params[:id])
  end
end

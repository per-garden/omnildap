class BackendsController < ApplicationController
  before_filter :require_admin

  def index
    @backends = Backend.all
  end
end

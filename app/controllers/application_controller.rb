class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper

  def render_not_found
    render :file => "./public/404.html",  :status => 404
  end
end

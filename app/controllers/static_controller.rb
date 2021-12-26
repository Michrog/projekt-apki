class StaticController < ApplicationController
  def index
    @users = User.all
    @posts = Post.all
    @profiles = Profile.all
  end

  before_action :require_token, only: [:feed]

  def feed
  end

end

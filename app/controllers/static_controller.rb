class StaticController < ApplicationController
  skip_before_action :verify_authenticity_token
  swagger_controller :static, "Static"
  before_action :require_token, only: [:index, :feed]

  def index
    @users = User.all
    @posts = Post.all
    @profiles = Profile.all
  end



  swagger_api :feed do
    summary 'Returns feed'
    param :header, "Authorization", :string, :required, "Authentication token"
    response :ok, "Pomyślne wyświetlenie feed'a."
    response :unauthorized, "Niepomyślna autoryzacja."
  end
  def feed
  end

end

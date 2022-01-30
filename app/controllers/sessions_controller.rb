class SessionsController < ApplicationController
  skip_before_action :verify_authenticity_token
  swagger_controller :session, "Authentication"

  def new
  end


swagger_api :create do
  summary "get token"
  param :form, "session[user_index]", :string, :required, "User's index"
  param :form, "session[password]", :string, :required, "User's password"
  response :ok, "Pomyślne zalogowanie i zwrócenie tokenu"
  response :unprocessable_entity, "Błędne dane."
end
  def create
    respond_to do |format|

      user = User.find_by(user_index: params[:session][:user_index])

      if user && user.authenticate(params[:session][:password])
        #git
        format.html  {
          log_in user
          redirect_to user
        }
        format.json {
          user.password = params[:session][:password]
          user.regenerate_token
          render json: { token: user.token }
        }
      else
        #ngit
        format.html {
          render 'new'
        }
        format.json {
          render json: { message: 'Niepoprawne dane' }, status: :unprocessable_entity
        }
      end
    end
  end

  swagger_api :destroy do
    summary "invalidate token"
    param :form, "session[user_index]", :string, :required, "User's index"
    response :ok, "Pomyślne zalogowanie i zwrócenie tokenu"
  end
  def destroy
    respond_to do |format|
      format.html do
        log_out
        redirect_to root_url
      end
      format.json do
        require_token
        if current_user
          current_user.invalidate_token
          head :ok
        end
      end
    end
  end

end

class UsersController < ApplicationController
  before_action :set_user, only: %i[ show edit update destroy ]
  swagger_controller :users, "Users"
  skip_before_action :verify_authenticity_token

  # GET /users or /users.json
  swagger_api :index do
    summary 'Returns all users'
    notes 'notes'
  end
  def index
    @users = User.all
  end

  # GET /users/1 or /users/1.json
  swagger_api :show do
    summary 'returns one user'
    param :path, :id, :integer, :required, "User's id"
    notes 'notes'
  end

  def show
    @user = User.find(params[:id])
  end

  # GET /users/new
  def new
    @user = User.new
  end

  def profiles
  end

  def setProfile
    @user = User.find_by(id: params[:id])
    @user.current_profile_id = params[:current_profile_id]
    @user.save(validate: false)

    redirect_to current_user
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users or /users.json
  swagger_api :create do
    summary "create a user"
    param :form, "user[name]", :string, :required, "User's name"
    param :form, "user[user_index]", :string, :required, "User's index"
    param :form, "user[password]", :string, :required, "User's password"
  end
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: "User was successfully created." }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1 or /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: "User was successfully updated." }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1 or /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: "User was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      if !User.exists?(params[:id])
        render_not_found
      else
        @user = User.find(params[:id])
      end
    end

    # Only allow a list of trusted parameters through.
    def user_params
      params.require(:user).permit(:name, :last_name, :user_type, :user_index, :password, :password_confirmation)
    end

end

class UsersController < ApplicationController
  before_action :set_user, only: %i[ show edit update destroy ]
  swagger_controller :users, "Users"
  skip_before_action :verify_authenticity_token
  before_action :require_token, only: [:show, :index, :setProfile, :destroy, :update]

  # GET /users or /users.json
  swagger_api :index do
    summary 'Returns all users'
    param :header, "Authorization", :string, :required, "Authentication token"
    response :ok, "Pomyślne wyświetlenie użytkowników"
  end
  def index
    @users = User.all
  end

  # GET /users/1 or /users/1.json
  swagger_api :show do
    summary 'returns one user'
    param :header, "Authorization", :string, :required, "Authentication token"
    param :path, :id, :integer, :required, "User's id"
    response :ok, "Pomyślne wyświetlenie użytkownika"
    response :not_found, "Nie ma takiego użytkownika"
  end
  def show
    @user = User.find(params[:id])
  end

  # GET /users/new
  def new
    @user = User.new
  end

#nie istnieje
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
    param :form, "user[last_name]", :string, :required, "User's name"
    param :form, "user[user_index]", :string, :required, "User's index"
    param :form, "user[password]", :string, :required, "User's password"
    param :form, "user[user_type]", :string, :required, "User's type"
    response :created, "Pomyślne utworzenie użytkownika."
    response :unprocessable_entity, "Źle podane dane."
  end
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        format.html { redirect_to login_path, notice: "User was successfully created." }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1 or /users/1.json
  swagger_api :update do
    summary "update a user"
    param :header, "Authorization", :string, :required, "Authentication token"
    param :path, :id, :integer, :required, "User's id"
    param :form, "user[current_profile_id]", :integer, :optional, "User's current profile"
    param :form, "user[password]", :string, :required, "User's password"
    param :form, "user[password_confirmation]", :string, :required, "password confirmation"
    param :form, "user[name]", :string, :optional, "User's name"
    param :form, "user[last_name]", :string, :optional, "User's name"
    param :form, "user[user_index]", :string, :optional, "User's index"
    param :form, "user[user_type]", :string, :optional, "User's type"
    response :ok, "Pomyślne utworzenie użytkownika."
    response :unauthorized, "Niepomyślna autoryzacja (zły token)."
    response :not_found, "Profil nie istnieje."
    response :forbidden, "Próba edycji innego użytkownika lub profil nie należy do użytkownika."
    response :unprocessable_entity, "Niepoprawne dane."
  end
  def update

    profile = Profile.find_by(id: user_params[:current_profile_id])

    if user_params[:current_profile_id] == nil #bez profilu
      respond_to do |format|
        if current_user.id != params[:id].to_i
          format.html { render :edit, status: :forbidden }
          format.json { render json: {"error": "Nie możesz edytować innych użytkowników", "id": params[:id].to_i}, status: :forbidden }
        elsif @user.update(user_params)
          format.html { redirect_to @user, notice: "User was successfully updated." }
          format.json { render :show, status: :ok, location: @user }
        else
          format.html { render :edit, status: :unprocessable_entity }
          format.json { render json: @user.errors, status: :unprocessable_entity }
        end
      end
    elsif profile == nil #profil nie istnieje
      respond_to do |format|
        format.html { render :edit, status: :not_found }
        format.json { render json: {"error": "Profil nie istnieje", "profile_id": user_params[:current_profile_id].to_i}, status: :not_found }
      end
    elsif profile.user_id == @user.id #z profilem
      respond_to do |format|
        if current_user.id != params[:id].to_i
          format.html { render :edit, status: :forbidden }
          format.json { render json: {"error": "Nie możesz edytować innych użytkowników"}, status: :forbidden }
        elsif @user.update(user_params)
          format.html { redirect_to @user, notice: "User was successfully updated." }
          format.json { render :show, status: :ok, location: @user }
        else
          format.html { render :edit, status: :unprocessable_entity }
          format.json { render json: @user.errors, status: :unprocessable_entity }
        end
      end
    else
      respond_to do |format|
        format.html { render :edit, status: :forbidden }
        format.json { render json: {"error": "ten profil nie należy do tego użytkownika"}, status: :forbidden }
      end
    end
  end

  # DELETE /users/1 or /users/1.json
  swagger_api :destroy do
    summary "delete a user"
    param :header, "Authorization", :string, :required, "Authentication token"
    param :path, :id, :integer, :required, "User's id"
    response :no_content, "Pomyślne usunięcie użytkownika."
    response :forbidden, "Próba usunięcia innego uzytkownika"
    response :unauthorized, "Niepomyślna autoryzacja (zły token)."
    response :not_found, "Użytkownik nie istnieje"
  end
  def destroy
    if current_user.id == params[:id].to_i
      @user.destroy
      respond_to do |format|
        format.html { redirect_to users_url, notice: "User was successfully destroyed." }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html { redirect_to users_url, notice: "Nie możesz usuwać innych użytkowników", status: :forbidden }
        format.json { render json: {"error": "Nie możesz usuwać innych użytkowników", "id": params[:id]}, status: :forbidden }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      #@user = User.find(params[:id])
      if User.find_by(id: params[:id]) != nil
        @user = User.find(params[:id])
      else
        respond_to do |format|
          format.html { redirect_to current_user, notice: "error", status: :not_found }
          format.json { render json: {"error": "Użytkownik nie istnieje."}, status: :not_found }
        end
      end
    end

    # Only allow a list of trusted parameters through.
    def user_params
      params.require(:user).permit(:name, :last_name, :user_type, :user_index, :password, :password_confirmation, :current_profile_id)
    end

end

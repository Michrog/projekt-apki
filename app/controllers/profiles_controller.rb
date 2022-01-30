class ProfilesController < ApplicationController
  before_action :set_profile, only: %i[ show edit update destroy ]
  swagger_controller :profiles, "Profiles"
  skip_before_action :verify_authenticity_token
  before_action :require_token, only: [:show, :index, :showForUser, :create, :destroy, :update]
  # GET /profiles or /profiles.json

  swagger_api :index do
    summary 'Returns all profiles'
    param :header, "Authorization", :string, :required, "Authorization token"
    response :ok, "Pomyślne zwrócenie profili."
    response :unauthorized, "Niepomyślna autoryzacja."
  end
  def index
    @profiles = Profile.all
  end

  # GET /profiles/1 or /profiles/1.json
  swagger_api :show do
    summary 'returns one profile'
    param :header, "Authorization", :string, :required, "Authorization token"
    param :path, :id, :integer, :required, "profile's id"
    response :ok, "Pomyślne zwrócenie profilu."
    response :unauthorized, "Niepomyślna autoryzacja."
    response :not_found, "Profil nie istnieje."
  end
  def show
  end

  swagger_api :showForUser do
    summary "returns user's profiles"
    param :header, "Authorization", :string, :required, "Authorization token"
    param :path, :id, :integer, :required, "user's id"
    response :ok, "Pomyślne zwrócenie profili użytkownika."
    response :unauthorized, "Niepomyślna autoryzacja."
    response :forbidden, "Próba przeglądania profili innego użytkownika."
    response :not_found, "Użytkownik nie istnieje."
  end
  def showForUser

    if current_user == User.find(params[:id])
      respond_to do |format|
        format.html { }
        format.json { render json: current_user.profiles, status: :ok}
      end
    elsif current_user != User.find(params[:id])
      respond_to do |format|
        format.html { }
        format.json { render json: {"error": "Nie możesz przeglądać profili innych użytkowników."}, status: :forbidden }
      end
    elsif User.exists?(id: params[:id])
      respond_to do |format|
        format.html { }
        format.json { render json: {"error": "Użytkownik nie istnieje."}, status: :not_found }
      end
    end
  end

  # GET /users/1/profiles/new
  def new
    @profile = Profile.new
  end

  # GET /profiles/1/edit
  def edit
  end

  # POST /users/1/profiles/new
  swagger_api :create do
    summary "create a profile"
    param :header, "Authorization", :string, :required, "Authentication token"
    param :path, :id, :integer, :required, "User's id"
    #param :form, "profile[user_id]", :integer, :required, "Profile's user (must be equal to :id in path)"
    param :form, "profile[name]", :string, :required, "profile's name"
    param :form, "profile[desc]", :text, :required, "profile's description"
    response :created, "Pomyślne stworzenie nowego profilu użytkownika."
    response :unauthorized, "Niepomyślna autoryzacja."
    response :forbidden, "Próba utworzenia profilu dla innego użytkownika."
    response :not_found, "Użytkownik nie istnieje."
  end
  def create
    profile_params[:user_id] = params[:id]
    user = User.find_by(id: params[:id])

    if user != nil && current_user == user
      respond_to do |format|
        @profile = Profile.new(profile_params)
        @profile.user_id = user.id
        if @profile.save
          format.html { redirect_to current_user, notice: "Profile was successfully created." }
          format.json { render :show, status: :created, location: @profile }
        else
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: @profile.errors, status: :unprocessable_entity }
        end
      end
    elsif user == nil
      respond_to do |format|
        format.html { redirect_to current_user, notice: "error" , status: :not_found }
        format.json { render json: {"error": "Użytkownik nie istnieje."}, status: :not_found }
      end
    elsif current_user != user
      respond_to do |format|
        format.html { redirect_to current_user, notice: "error" , status: :forbidden }
        format.json { render json: {"error": "Nie możesz tworzyć profili dla innych użytkowników."}, status: :forbidden }
      end
    end
  end

  # PATCH/PUT /profiles/1 or /profiles/1.json
  swagger_api :update do
    summary "update a profile"
    param :header, "Authorization", :string, :required, "Authentication token"
    param :path, :id, :integer, :required, "Profile's id"
    param :form, "profile[name]", :string, :required, "profile's name"
    param :form, "profile[desc]", :string, :optional, "profile's description"
    response :ok, "Pomyślna edycja profilu."
    response :unauthorized, "Niepomyślna autoryzacja."
    response :not_found, "Profil nie istnieje."
    response :forbidden, "Profil nie należy do użytkownika."
  end
  def update
    profile = Profile.find_by(id: params[:id])

    if profile.in?(current_user.profiles) && profile != nil
      respond_to do |format|
        if @profile.update(profile_params)
          format.html { redirect_to @profile, notice: "Profile was successfully updated." }
          format.json { render :show, status: :ok, location: @profile }
        else
          format.html { render :edit, status: :unprocessable_entity }
          format.json { render json: @profile.errors, status: :unprocessable_entity }
        end
      end
    elsif profile.in?(current_user.profiles) == false
      respond_to do |format|
        format.html { redirect_to @profile, notice: "error", status: :forbidden }
        format.json { render json: {"error": "Nie możesz edytować profili, które nie należą do ciebie."}, status: :forbidden }
      end
    elsif profile == nil
      respond_to do |format|
        format.html { redirect_to @profile, notice: "error", status: :not_found }
        format.json { render json: {"error": "Profil nie istnieje."}, status: :not_found }
      end
    end
  end

  # DELETE /profiles/1 or /profiles/1.json
  swagger_api :destroy do
    summary "delete a profile"
    param :header, "Authorization", :string, :required, "Authentication token"
    param :path, :id, :integer, :required, "profile's id"
    response :no_content, "Pomyślne usunięcie profilu."
    response :unauthorized, "Niepomyślna autoryzacja."
    response :forbidden, "Próba usunięcia profilu, który nie należy do użytkownika."
    response :not_found, "Profil nie istnieje."
  end
  def destroy

    profile = Profile.find_by(id: params[:id])

    if profile.in?(current_user.profiles) && profile != nil
      @profile.destroy
      respond_to do |format|
        format.html { redirect_to profiles_url, notice: "Profile was successfully destroyed." }
        format.json { head :no_content }
      end
    elsif profile == nil
      respond_to do |format|
        format.html { redirect_to profiles_url, notice: "error", status: :not_found }
        format.json { render json: {"error": "Profil nie istnieje."}, status: :not_found }
      end
    elsif profile.in?(current_user.profiles) == false
      respond_to do |format|
        format.html { redirect_to profiles_url, notice: "error", status: :forbidden }
        format.json { render json: {"error": "Nie możesz usunąć profilu innego użytkownika."}, status: :forbidden }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_profile
      if Profile.find_by(id: params[:id]) != nil
        @profile = Profile.find(params[:id])
      else
        respond_to do |format|
          format.html { redirect_to current_user, notice: "error", status: :not_found }
          format.json { render json: {"error": "Profil nie istnieje."}, status: :not_found }
        end
      end
    end

    # Only allow a list of trusted parameters through.
    def profile_params
      params.require(:profile).permit(:name, :picture, :desc, :user_id)
    end
end

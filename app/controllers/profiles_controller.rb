class ProfilesController < ApplicationController
  before_action :set_profile, only: %i[ show edit update destroy ]
  swagger_controller :posts, "Posts"
  skip_before_action :verify_authenticity_token

  # GET /profiles or /profiles.json
  swagger_api :index do
    summary 'Returns all profiles'
    notes 'notes'
  end
  def index
    @profiles = Profile.all
  end

  # GET /profiles/1 or /profiles/1.json
  swagger_api :show do
    summary 'returns one profile'
    param :path, :id, :integer, :required, "profile's id"
    notes 'notes'
  end

  def show
  end

  def showForUser
    @user = User.find(params[:id])

    respond_to do |format|
      format.html { }
      format.json { render json: @user.profiles, code: '200' }
    end

  end

  # GET /profiles/new
  def new
    @profile = Profile.new
  end

  # GET /profiles/1/edit
  def edit
  end

  # POST /profiles or /profiles.json
  swagger_api :create do
    summary "create a profile"
    param :form, "profile[name]", :string, :required, "profile's name"
    param :form, "profile[description]", :text, :required, "profile's description"
  end
  def create
    @profile = Profile.new(profile_params)

    respond_to do |format|
      if @profile.save
        format.html { redirect_to @profile, notice: "Profile was successfully created." }
        format.json { render :show, status: :created, location: @profile }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @profile.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /profiles/1 or /profiles/1.json
  def update
    respond_to do |format|
      if @profile.update(profile_params)
        format.html { redirect_to @profile, notice: "Profile was successfully updated." }
        format.json { render :show, status: :ok, location: @profile }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @profile.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /profiles/1 or /profiles/1.json
  def destroy
    @profile.destroy
    respond_to do |format|
      format.html { redirect_to profiles_url, notice: "Profile was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_profile
      @profile = Profile.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def profile_params
      params.require(:profile).permit(:name, :picture, :desc, :user_id)
    end
end

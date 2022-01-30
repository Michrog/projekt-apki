class PostsController < ApplicationController
  before_action :set_post, only: %i[ show edit update destroy ]
  skip_before_action :verify_authenticity_token
  before_action :require_token, only: [:index, :show, :create, :destroy, :update]
  swagger_controller :posts, "Posts"

  # GET /posts or /posts.json
  swagger_api :index do
    summary 'returns all posts'
    param :header, "Authorization", :string, :required, "Authentication token"
    response :ok, "Zwrócenie wszystkich postów."
    response :unauthorized, "Niepomyślna autoryzacja"
  end
  def index
    @posts = Post.all
  end

  # GET /posts/1 or /posts/1.json
  swagger_api :show do
    summary 'returns one post'
    param :header, "Authorization", :string, :required, "Authentication token"
    param :path, :id, :integer, :required, "Post's id"
    response :ok, "Zwrócenie posta."
    response :not_found, "Post nie istnieje."
    response :unauthorized, "Niepomyślna autoryzacja."
  end
  def show
  end

  # GET /posts/new
  def new
    @post = Post.new
  end

  # GET /posts/1/edit
  def edit
  end

  swagger_api :create do
    summary "create a post"
    param :header, "Authorization", :string, :required, "Authentication token"
    param :path, :id, :integer, :required, "user's id"
    param :form, "post[title]", :string, :required, "Post's title"
    param :form, "post[content]", :string, :required, "Post's content"
    param :form, "post[profile_id]", :integer, :required, "Post's author"
    response :created, "Pomyślne stworzenie posta."
    response :forbidden, "Próba utworzenia posta autorstwa innego użytkownika lub obcego profilu."
    response :not_found, "Próba utworzenia posta autorstwa użytkownika lub profilu które nie istnieje."
  end
  def create
    @post = Post.new(post_params)

     profile = Profile.find_by(id: post_params[:profile_id])
     user = User.find_by(id: params[:id])

    if user == current_user && profile.in?(current_user.profiles)
      respond_to do |format|
        if @post.save
          format.html { redirect_to current_user, notice: "Post was successfully created." }
          format.json { render :show, status: :created, location: @post }
        else
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: @post.errors, status: :unprocessable_entity }
        end
      end
    elsif user == nil
      respond_to do |format|
        format.html {redirect_to current_user, notice: "Błąd", status: :not_found}
        format.json {render json: {"error": "Nie możesz tworzyć posta jako użytkownik, który nie istnieje.", "id": params[:id]}, status: :not_found}
      end
    elsif user != current_user
      respond_to do |format|
        format.html {redirect_to current_user, notice: "Błąd", status: :forbidden}
        format.json {render json: {"error": "Nie możesz tworzyć posta jako inny użytkownik."}, status: :forbidden}
      end
    elsif profile == nil
      respond_to do |format|
        format.html {redirect_to current_user, notice: "Błąd", status: :not_found}
        format.json {render json: {"error": "Nie możesz tworzyć posta autorstwa profilu, który nie istnieje."}, status: :not_found}
      end
    else profile.in?(current_user.profiles) == false
      respond_to do |format|
        format.html {redirect_to current_user, notice: "Błąd", status: :forbidden}
        format.json {render json: {"error": "Nie możesz tworzyć posta autorstwa obcego profilu"}, status: :forbidden}
      end
    end
  end

  # PATCH/PUT /posts/1 or /posts/1.json
  swagger_api :update do
    summary "update a post"
    param :header, "Authorization", :string, :required, "Authentication token"
    param :path, :id, :integer, :required, "posts's id"
    param :form, "post[profile_id]", :integer, :required, "Post's author"
    param :form, "post[title]", :string, :optional, "Post's title"
    param :form, "post[content]", :string, :optional, "Post's content"
    response :ok, "Pomyślna edycja posta."
    response :forbidden, "Próba edycji posta nie należy do użytkownika."
    response :not_found, "Próba edycji posta lub jego autora, który nie istnieje."
  end
  def update

    post = Post.find_by(id: params[:id])
    o_profile = Profile.find_by(id: post.profile_id)
    profile = Profile.find_by(id: post_params[:profile_id])

    if post != nil && o_profile.in?(current_user.profiles) && profile.in?(current_user.profiles)
      respond_to do |format|
        if @post.update(post_params)
          format.html { redirect_to @post, notice: "Post was successfully updated." }
          format.json { render :show, status: :ok, location: @post }
        else
          format.html { render :edit, status: :unprocessable_entity }
          format.json { render json: @post.errors, status: :unprocessable_entity }
        end
      end
    elsif @post == nil
      respond_to do |format|
          format.html { redirect_to current_user, notice: "error", status: :not_found }
          format.json { render json: {"error": "Post nie istnieje."}, status: :not_found }
      end
    elsif Profile.find_by(id: post_params[:profile_id]) == nil
      respond_to do |format|
        format.html { redirect_to current_user, notice: "error", status: :not_found }
        format.json { render json: {"error": "Profil nie istnieje."}, status: :not_found }
      end
    elsif o_profile.in?(current_user.profiles) == false
      respond_to do |format|
        format.html { redirect_to current_user, notice: "error", status: :forbidden }
        format.json { render json: {"error": "Post nie należy do ciebie."}, status: :forbidden }
      end
    elsif profile.in?(current_user.profiles) == false
      respond_to do |format|
        format.html { redirect_to current_user, notice: "error", status: :forbidden }
        format.json { render json: {"error": "Profil nie należy do ciebie."}, status: :forbidden }
      end
    end
  end

  # DELETE /posts/1 or /posts/1.json
  swagger_api :destroy do
    summary "delete a post"
    param :header, "Authorization", :string, :required, "Authentication token"
    param :path, :id, :integer, :required, "Post's id"
    response :no_content, "Pomyślne usunięcie posta."
    response :forbidden, "Próba usunięcia posta innego uzytkownika."
    response :unauthorized, "Niepomyślna autoryzacja (zły token)."
    response :not_found, "Post nie istnieje."
  end
  def destroy
    post = Post.find_by(id: params[:id])
    profile = Profile.find_by(id: post.profile_id)

    if post != nil && profile.in?(current_user.profiles)
      @post.destroy
      respond_to do |format|
        format.html { redirect_to posts_url, notice: "Post was successfully destroyed." }
        format.json { head :no_content }
      end
    elsif post == nil
      respond_to do |format|
        format.html { redirect_to posts_url, notice: "error", status: :not_found }
        format.json { render json: {"error": "Post nie istnieje."}, status: :not_found }
      end
    elsif profile.in?(current_user.profiles) == false
      respond_to do |format|
        format.html { redirect_to posts_url, notice: "error", status: :forbidden }
        format.json { render json: {"error": "Ten post nie należy do ciebie."}, status: :forbidden }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_post
      #@post = Post.find(params[:id])
      if Post.find_by(id: params[:id]) != nil
        @post = Post.find(params[:id])
      else
        respond_to do |format|
          format.html { redirect_to current_user, notice: "error", status: :not_found }
          format.json { render json: {"error": "Post nie istnieje."}, status: :not_found }
        end
      end
    end

    # Only allow a list of trusted parameters through.
    def post_params
      params.require(:post).permit(:content, :post_date, :post_group, :title, :profile_id)
    end
end

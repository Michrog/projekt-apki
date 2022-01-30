class CommentsController < ApplicationController
  before_action :set_comment, only: %i[ show edit update destroy ]
  swagger_controller :comments, "Comments"
  skip_before_action :verify_authenticity_token
  before_action :require_token, only: [:index, :show, :create, :destroy, :update]

  # GET /comments or /comments.json
  swagger_api :index do
    summary 'Returns all comments'
    param :header, "Authorization", :string, :required, "Authentication token"
    response :ok, "Pomyślne zwrócenie komentarzy."
    response :unauthorized, "Niepomyślna autoryzacja."
  end
  def index
    @comments = Comment.all
  end

  # GET /comments/1 or /comments/1.json
  swagger_api :show do
    summary 'Returns one comment'
    param :header, "Authorization", :string, :required, "Authentication token"
    param :path, :id, :integer, :required, "Comment's id"
    response :ok, "Pomyślne zwrócenie komentarza."
    response :unauthorized, "Niepomyślna autoryzacja."
    response :not_found, "Komentarz nie istnieje."
  end
  def show
  end

  # GET /comments/new
  def new
    @comment = Comment.new
  end

  # GET /comments/1/edit
  def edit
  end

  # POST /posts/id /comments/new
  swagger_api :create do
    summary "create a comment"
    param :header, "Authorization", :string, :required, "Authentication token"
    param :path, :id, :integer, :required, "post's id"
    param :form, "comment[content]", :string, :oprional, "comment's content"
    param :form, "comment[profile_id]", :integer, :required, "comment's author"
    #param :form, "comment[post_id]", :integer, :required, "comment's post"
    response :created, "Pomyślne stworzenie komentarza profilu użytkownika pod postem."
    response :unauthorized, "Niepomyślna autoryzacja."
    response :forbidden, "Próba utworzenia komentarza autorstwa profilu, który nie należy do użytkownika."
    response :not_found, "Próba utworzenia komentarza autorstwa profilu, który nie istnieje lub pod postem, który nie istnieje."
  end
  def create

    comment_params[:post_id] = params[:id]

    @comment = Comment.new(comment_params)
    post = Post.find_by(id: params[:id])
    if post != nil
      @comment.post_id = post.id
    end
    profile = Profile.find_by(id: @comment.profile_id)

    if post != nil && profile != nil && profile.in?(current_user.profiles)
      respond_to do |format|
        if @comment.save
          format.html { redirect_to post, notice: "Comment was successfully created." }
          format.json { render :show, status: :created, location: @comment }
        else
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: @comment.errors, status: :unprocessable_entity }
        end
      end
    elsif post == nil || profile == nil
      respond_to do |format|
        format.html { redirect_to post, notice: "error", status: :not_found }
        format.json { render json: {"error": "Profil lub post nie istnieje."}, status: :not_found }
      end
    elsif profile.in?(current_user.profiles) == false
      respond_to do |format|
        format.html { redirect_to post, notice: "error", status: :forbidden }
        format.json { render json: {"error": "Profil nie należy do ciebie."}, status: :forbidden }
      end
    end
  end

  # PATCH/PUT /comments/1 or /comments/1.json
  swagger_api :update do
    summary "update a comment"
    param :header, "Authorization", :string, :required, "Authentication token"
    param :path, :id, :integer, :required, "comment's id"
    param :form, "comment[content]", :string, :optional, "comment's content"
    param :form, "comment[profile_id]", :integer, :required, "comment's author"
    param :form, "comment[post_id]", :integer, :required, "comment's post"
    response :created, "Pomyślna edycja komentarza profilu użytkownika pod postem."
    response :unauthorized, "Niepomyślna autoryzacja."
    response :forbidden, "Próba edycji komentarza, który nie należy do profilu użytkownika lub ustawienie jako autora komentarza profil, który nie należy do użytkownika."
    response :not_found, "Próba edycji komentarza, który nie istnieje lub którego autor nie istnieje lub pod postem, który nie istnieje."
  end
  def update

    comment = Comment.find_by(id: params[:id])
    o_profile_com = Profile.find_by(id: comment.profile_id)
    post = Post.find_by(id: comment_params[:post_id])
    profile = Profile.find_by(id: comment_params[:profile_id])

    if comment != nil && post != nil && profile.in?(current_user.profiles) && o_profile_com.user_id == current_user.id
      respond_to do |format|
        if @comment.update(comment_params)
          format.html { redirect_to @comment, notice: "Comment was successfully updated." }
          format.json { render :show, status: :ok, location: @comment }
        else
          format.html { render :edit, status: :unprocessable_entity }
          format.json { render json: @comment.errors, status: :unprocessable_entity }
        end
      end
    elsif comment == nil || post == nil || profile == nil
      respond_to do |format|
        format.html { redirect_to post, notice: "error", status: :not_found }
        format.json { render json: {"error": "Komentarz, profil lub post nie istnieje."}, status: :not_found }
      end
    elsif profile.in?(current_user.profiles) == false
      respond_to do |format|
        format.html { redirect_to post, notice: "error", status: :forbidden }
        format.json { render json: {"error": "Profil nie należy do ciebie."}, status: :forbidden }
      end
    elsif o_profile_com.user_id != current_user.id
      respond_to do |format|
        format.html { redirect_to post, notice: "error", status: :forbidden }
        format.json { render json: {"error": "Komentarz nie należy do ciebie."}, status: :forbidden }
      end
    end
  end

  # DELETE /comments/1 or /comments/1.json
  swagger_api :destroy do
    summary "delete a comment"
    param :header, "Authorization", :string, :required, "Authentication token"
    param :path, :id, :integer, :required, "comment's id"
    response :no_content, "Pomyślne usunięcie komentarza profilu użytkownika pod postem."
    response :unauthorized, "Niepomyślna autoryzacja."
    response :forbidden, "Próba usunięcia komentarza autorstwa profilu, który nie należy do użytkownika."
    response :not_found, "Próba usunięcia komentarza, który nie istnieje."
  end
  def destroy

    comment = Comment.find_by(id: params[:id])
    o_profile_com = Profile.find_by(id: comment.profile_id)

    if comment != nil && o_profile_com.in?(current_user.profiles)
      @comment.destroy
      respond_to do |format|
        format.html { redirect_to comments_url, notice: "Comment was successfully destroyed." }
        format.json { head :no_content }
      end
    elsif Comment.exists?(id: params[:id]) == false
      respond_to do |format|
        format.html { redirect_to comments_url, notice: "error", status: :not_found }
        format.json { render json: {"error": "Komentarz nie istnieje."}, status: :not_found }
      end
    elsif o_profile_com.in?(current_user.profiles) == false
      respond_to do |format|
        format.html { redirect_to comments_url, notice: "error", status: :forbidden }
        format.json { render json: {"error": "Komentarz nie należy do ciebie."}, status: :forbidden }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_comment
      #@comment = Comment.find(params[:id])
      if Comment.find_by(id: params[:id]) != nil
        @comment = Comment.find(params[:id])
      else
        respond_to do |format|
          format.html { redirect_to current_user, notice: "error", status: :not_found }
          format.json { render json: {"error": "Komentarz nie istnieje."}, status: :not_found }
        end
      end
    end

    # Only allow a list of trusted parameters through.
    def comment_params
      params.require(:comment).permit(:content, :comment_date, :comment_time, :profile_id, :post_id)
    end
end

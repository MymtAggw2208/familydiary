class DiariesController < ApplicationController
  before_action :authenticate_user!, only: %i[ new edit destroy ]
  before_action :set_diary, only: %i[ show edit update destroy ]


  # GET /diaries or /diaries.json
  def index
    @diaries = Diary.all.order(created_at: :desc)
  end

  # GET /diaries/1 or /diaries/1.json
  def show
    @comment = Comment.new
    @comments = @diary.comments.includes(:user).order(created_at: :asc)
  end

  # GET /diaries/new
  def new
    @diary = current_user.diaries.build
  end

  # GET /diaries/1/edit
  def edit
    authorize_diary_owner("編集")
  end

  # POST /diaries or /diaries.json
  def create
    @diary = current_user.diaries.build(diary_params)

    respond_to do |format|
      if @diary.save
        format.html { redirect_to @diary, notice: "日記を登録しました。" }
        format.json { render :show, status: :created, location: @diary }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @diary.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /diaries/1 or /diaries/1.json
  def update
    respond_to do |format|
      authorize_diary_owner("更新")
      if @diary.update(diary_params)
        format.html { redirect_to @diary, notice: "日記を更新しました。" }
        format.json { render :show, status: :ok, location: @diary }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @diary.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /diaries/1 or /diaries/1.json
  def destroy
    respond_to do |format|
      authorize_diary_owner("削除")
      @diary.destroy!
      format.html { redirect_to diaries_path, status: :see_other, notice: "日記を削除しました。" }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_diary
      @diary = Diary.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def diary_params
      params.expect(diary: [ :title, :description, :picture, :published_at ])
    end

    # 日記操作権限
    def authorize_diary_owner(action)
      require_owner_permission(@diary, "この日記を#{action}する権限がありません。")
    end
end

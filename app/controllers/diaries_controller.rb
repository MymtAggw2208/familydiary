class DiariesController < ApplicationController
  before_action :authenticate_user!, only: %i[ new edit destroy ]
  before_action :set_diary, only: %i[ show edit update destroy ]


  # GET /diaries or /diaries.json
  def index
    @diaries = Diary.all
  end

  # GET /diaries/1 or /diaries/1.json
  def show
    @comment = Comment.new
    @comments = @diary.comments.includes(:user).order(created_at: :asc)
  end

  # GET /diaries/new
  def new
    @diary = Diary.new
  end

  # GET /diaries/1/edit
  def edit
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
      if @diary.user == current_user
        if @diary.update(diary_params)
          format.html { redirect_to @diary, notice: "日記を更新しました。" }
          format.json { render :show, status: :ok, location: @diary }
        else
          format.html { render :edit, status: :unprocessable_entity }
          format.json { render json: @diary.errors, status: :unprocessable_entity }
        end
      else
        redirect_to @comment.diary, alert: '編集権限がありません。'
      end
    end
  end

  # DELETE /diaries/1 or /diaries/1.json
  def destroy
    respond_to do |format|
      if @diary.user == current_user
        @diary.destroy!
        format.html { redirect_to diaries_path, status: :see_other, notice: "日記を削除しました。" }
        format.json { head :no_content }
      else
        redirect_to @comment.diary, alert: '削除権限がありません。'
      end
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
end

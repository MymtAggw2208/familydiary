class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_diary, only: [ :create ]
  before_action :set_comment, only: [ :destroy ]

  def create
    @comment = current_user.comments.build(comment_params.merge(diary: @diary))

    if @comment.save
      redirect_to @diary, notice: 'コメントを投稿しました。'
    else
      @comments = @diary.comments.includes(:user).order(created_at: :asc)
      render 'diaries/show'
    end
  end

  def destroy
    @diary = Diary.find(params[:diary_id])
    @comment = @diary.comments.find(params[:id])
    authorize_comment_owner("削除")
    @comment.destroy
  end

  private

  def set_diary
    @diary = Diary.find(params[:diary_id])
  end

  def set_comment
    @comment = current_user.comments.find(params[:id])
  end

  def comment_params
    params.require(:comment).permit(:content)
  end

  def authorize_comment_owner(action)
    require_owner_permission(@comment, "このコメントを#{action}する権限がありません。")
  end
end

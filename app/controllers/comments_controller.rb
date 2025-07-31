class CommentsController < ApplicationController
  before_action :set_diary, only: [:create]
  before_action :set_comment, only: [:destroy]

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
    if @comment.user == current_user
      @comment.destroy
      redirect_to @comment.diary, notice: 'コメントを削除しました。'
    else
      redirect_to @comment.diary, alert: '削除権限がありません。'
    end
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
end

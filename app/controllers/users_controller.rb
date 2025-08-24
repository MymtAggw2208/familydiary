class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :require_administrator, only: [ :index ]
  before_action :require_user_access_permission, only: [ :show ]
  before_action :set_user, only: [ :show ]

  def index
    @users = User.all.order(login_id: :asc)
  end

  def show
  end

  private

  def set_user
    @user = User.find(params[:id])
  end
end

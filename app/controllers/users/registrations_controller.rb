# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  skip_before_action :require_no_authentication, only: %i[ new create ]
  skip_before_action :authenticate_scope!, only: %i[ new create ]
  before_action :authenticate_user_for_admin_actions!, only: %i[ new create ]
  before_action :require_administrator, only: %i[ new create ]
  before_action :require_user_access_permission, only: %i[ edit update destroy ]

  # GET /users/sign_up
  def new
    build_resource
    yield resource if block_given?
    respond_with resource
  end

  # POST /users
  def create
    build_resource(sign_up_params)
    
    resource.save
    yield resource if block_given?
    if resource.persisted?
      if resource.active_for_authentication?
        set_flash_message! :notice, :signed_up
        # 管理者が作成した場合はログインせずにユーザー一覧にリダイレクト
        redirect_to users_path
      else
        set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
        expire_data_after_sign_in!
        redirect_to users_path
      end
    else
      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource
    end
  end

  # GET /users/edit
  def edit
    # params[:id]がある場合は他のユーザーの編集、ない場合は自分の編集
    if params[:id].present?
      self.resource = User.find(params[:id])
    else
      self.resource = current_user
    end
    render :edit
  end

  # PUT /users 
  def update
    # params[:id]がある場合は他のユーザーの更新、ない場合は自分の更新
    if params[:id].present?
      self.resource = User.find(params[:id])
    else
      self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
    end
    
    prev_unconfirmed_email = resource.unconfirmed_email if resource.respond_to?(:unconfirmed_email)

    # パスワード更新のチェック
    if account_update_params[:password].blank? && account_update_params[:password_confirmation].blank?
      update_params = account_update_params.except(:password, :password_confirmation, :current_password)
      resource_updated = update_resource_without_password(resource, update_params)
    else
      resource_updated = update_resource(resource, account_update_params)
    end

    yield resource if block_given?
    if resource_updated
      set_flash_message_for_update(resource, prev_unconfirmed_email)
      
      # 管理者が他のユーザーを編集した場合と自分を編集した場合で分岐
      if params[:id].present? && current_user.administrator?
        # 他のユーザーを編集した場合
        redirect_to user_path(resource), notice: 'ユーザー情報が正常に更新されました。'
      else
        # 自分を編集した場合
        bypass_sign_in resource, scope: resource_name if sign_in_after_change_password?
        respond_with resource, location: after_update_path_for(resource)
      end
    else
      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource
    end
  end

  # DELETE /users
  def destroy
    if params[:id].present? && current_user.administrator?
      # 管理者が他のユーザーを削除する場合
      self.resource = User.find(params[:id])
      if resource != current_user
        resource.destroy
        set_flash_message! :notice, :destroyed
        redirect_to users_path
      else
        redirect_to users_path, alert: '自分自身は削除できません。'
      end
    else
      # 自分自身を削除する場合の通常のDevise処理
      super
    end
  end

  protected

  # 新規登録時のパラメータ
  def sign_up_params
    params.require(:user).permit(:name, :login_id, :email, :password, :password_confirmation, :role_type)
  end

  # 更新時のパラメータ
  def account_update_params
    if current_user.administrator?
      params.require(:user).permit(:name, :email, :password, :password_confirmation, :current_password, :role_type)
    else
      params.require(:user).permit(:name, :email, :password, :password_confirmation, :current_password)
    end
  end

  private

  def update_resource_without_password(resource, params)
    resource.update_without_password(params)
  end

  def sign_in_after_change_password?
    true
  end
  
  def authenticate_user_for_admin_actions!
    redirect_to new_user_session_path unless user_signed_in?
  end
end

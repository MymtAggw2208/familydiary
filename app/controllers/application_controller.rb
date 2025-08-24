class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  protected
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :name, :login_id, :email, :role_type ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :name, :login_id, :email, :role_type ])
    devise_parameter_sanitizer.permit(:sign_in, keys: [ :login_id ])
  end

  # 管理者権限チェック
  def require_administrator
    unless current_user&.administrator?
      redirect_to root_path, alert: "アクセス権限がありません。"
    end
  end

  # ユーザーアクセス権限チェック（共通メソッド）
  def require_user_access_permission(action_type = :edit)
    # 編集対象のユーザーを特定
    if params[:id].present?
      @target_user = User.find(params[:id])
    else
      @target_user = current_user
    end

    unless current_user.can_edit_user?(@target_user)
      case action_type
      when :view
        redirect_to root_path, alert: "このユーザーの情報を閲覧する権限がありません。"
      when :edit
        redirect_to root_path, alert: "このユーザーの情報を編集する権限がありません。"
      else
        redirect_to root_path, alert: "このユーザーにアクセスする権限がありません。"
      end
    end
  end

  # 汎用編集権限チェック
  def require_owner_permission(resource, error_message = "このリソースを操作する権限がありません。")
    unless can_modify_resource?(resource)
      redirect_to root_path, alert: error_message
    end
  end

  # リソース変更可否チェック
  def can_modify_resource?(resource)
    return false unless current_user
    return true if current_user.administrator?
    return true if resource.respond_to?(:user) && resource.user == current_user
    false
  end

  # ログイン後のリダイレクト先
  def after_sign_in_path_for(resource)
    # Deviseが保存した元のURLがあればそこにリダイレクト
    stored_location_for(resource) || root_path
  end

  # ログアウト後のリダイレクト先
  def after_sign_out_path_for(resource)
    # ログアウト前にいたページに戻る
    request.referer || root_path
  end
end

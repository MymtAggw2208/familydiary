class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  protected
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :login_id, :email])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name, :login_id, :email])
    devise_parameter_sanitizer.permit(:sign_in, keys: [:login_id])
  end
end

class ApplicationController < ActionController::Base
  allow_browser versions: :modern

  before_action :set_theme
  before_action :authenticate_user!, unless: :public_page?
  before_action :set_user, if: :user_signed_in?

  protected

  def after_sign_in_path_for(_resource)
    root_path
  end

  def after_sign_up_path_for(_resource)
    root_path
  end

  def set_theme
    cookies[:theme] = "light"
  end

  private

  def public_page?
    request.path == root_path
  end

  def set_user
    @user = current_user
  end
end

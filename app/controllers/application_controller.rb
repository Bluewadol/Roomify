class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  before_action :set_theme

  def set_theme
    if cookies[:theme].blank?
      cookies[:theme] = "media" 
    end
  end

end

class ErrorsController < ApplicationController
  skip_before_action :authenticate_user!
  
  def not_found
    render status: :not_found, layout: "application"
  end

  def internal_server_error
    render status: :internal_server_error, layout: "application"
  end

  def unprocessable_entity
    render status: :unprocessable_entity, layout: "application"
  end
end 
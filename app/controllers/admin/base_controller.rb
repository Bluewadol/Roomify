class Admin::BaseController < ApplicationController
    before_action :authorize_admin

    private

    def authorize_admin
        redirect_to root_path, alert: "You are not authorized to access this page" unless current_user.has_role?(:admin)
    end
end

class Admin::BaseController < ApplicationController
    before_action :authorize_admin

    private

    def authorize_admin
        redirect_to root_path, alert: "คุณไม่มีสิทธิ์เข้าถึงหน้านี้" unless current_user.has_role?(:admin)
    end
end

class User::AccountController < ApplicationController
    before_action :set_user

    def show
    end

    def edit
    end

    def update
        @user = current_user

        if password_change_requested?
            if @user.valid_password?(params[:user][:current_password])
                if @user.update(user_params_with_password)
                    bypass_sign_in(@user)
                    redirect_to account_path, notice: "Profile & password updated."
                else
                    render :edit, status: :unprocessable_entity
                end
            else
                @user.errors.add(:current_password, "is incorrect")
                render :edit, status: :unprocessable_entity
            end
        else
            if @user.update(user_params_without_password)
                redirect_to account_path, notice: "Profile updated."
            else
                render :edit, status: :unprocessable_entity
            end
        end
    end

    private

    def set_user
        @user = current_user
    end

    def password_change_requested?
        params[:user][:password].present?
    end

    def user_params_with_password
        params.require(:user).permit(:name, :phone_number, :avatar, :password, :password_confirmation)
    end

    def user_params_without_password
        params.require(:user).permit(:name, :phone_number, :avatar)
    end
end

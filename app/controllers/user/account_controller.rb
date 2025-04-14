class User::AccountController < ApplicationController
    before_action :set_user

    def show
    end

    def edit
    end

    def update

        
        # Handle password changes separately
        if user_params[:password].present? && user_params[:password_confirmation].present?
            if @user.update_with_password(user_params)
                sign_in(@user, bypass: true)
                redirect_to account_path, notice: "Password updated successfully."
                return
            end
        else
            if @user.update(user_params.except(:password, :password_confirmation, :current_password))
                redirect_to account_path, notice: "Account updated successfully."
                return
            end
        end

        flash.now[:alert] = @user.errors.full_messages.to_sentence
        render :edit, status: :unprocessable_entity
    end

    private

    def set_user
        @user = current_user
    end

    def user_params
        params.require(:user).permit(
            :name,
            :phone_number,
            :avatar,
            :password,
            :password_confirmation,
            :current_password
        ).tap do |whitelisted|
            # Remove avatar if it's a string (from form submission)
            whitelisted.delete(:avatar) if whitelisted[:avatar].is_a?(String)
            # Remove blank password fields
            whitelisted.delete(:password) if whitelisted[:password].blank?
            whitelisted.delete(:password_confirmation) if whitelisted[:password_confirmation].blank?
            whitelisted.delete(:current_password) if whitelisted[:current_password].blank?
        end
    end
end
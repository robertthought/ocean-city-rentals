module Owner
  class PasswordsController < ApplicationController
    layout 'owner_auth'

    def new
    end

    def create
      user = User.find_by(email: params[:email]&.downcase)

      if user
        user.generate_reset_token!
        OwnerMailer.password_reset(user).deliver_later
      end

      # Always show success to prevent email enumeration
      redirect_to owner_login_path, notice: "If an account exists with that email, you will receive password reset instructions."
    end

    def edit
      @user = User.find_by(reset_password_token: params[:token])

      if @user.nil? || !@user.reset_token_valid?
        redirect_to owner_forgot_password_path, alert: "Invalid or expired reset link. Please try again."
      end
    end

    def update
      @user = User.find_by(reset_password_token: params[:token])

      if @user.nil? || !@user.reset_token_valid?
        redirect_to owner_forgot_password_path, alert: "Invalid or expired reset link. Please try again."
        return
      end

      if @user.update(password_params)
        @user.clear_reset_token!
        session[:owner_id] = @user.id
        redirect_to owner_root_path, notice: "Password updated successfully!"
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def password_params
      params.require(:user).permit(:password, :password_confirmation)
    end
  end
end

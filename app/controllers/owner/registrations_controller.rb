module Owner
  class RegistrationsController < ApplicationController
    layout 'owner_auth'

    def new
      redirect_to owner_root_path if current_owner
      @user = User.new
    end

    def create
      @user = User.new(user_params)

      if @user.save
        session[:owner_id] = @user.id
        redirect_to owner_root_path, notice: "Welcome to OCNJ Weekly Rentals! You can now claim your properties."
      else
        render :new, status: :unprocessable_entity
      end
    end

    private

    def user_params
      params.require(:user).permit(:email, :password, :password_confirmation, :first_name, :last_name, :phone)
    end

    def current_owner
      @current_owner ||= User.find_by(id: session[:owner_id]) if session[:owner_id]
    end
    helper_method :current_owner
  end
end

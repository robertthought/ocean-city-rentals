module Owner
  class RegistrationsController < ApplicationController
    layout 'owner_auth'

    def new
      redirect_to owner_root_path if current_owner
      @user = User.new

      # Preserve return URL for after registration
      if params[:return_to].present?
        session[:return_to] = params[:return_to]
      end
    end

    def create
      @user = User.new(user_params)

      if @user.save
        session[:owner_id] = @user.id
        return_path = session.delete(:return_to) || owner_root_path
        redirect_to return_path, notice: "Welcome to OCNJ Weekly Rentals!"
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

module Owner
  class SessionsController < ApplicationController
    layout 'owner_auth'

    def new
      redirect_to owner_root_path if current_owner
    end

    def create
      user = User.find_by(email: params[:email]&.downcase)

      if user&.authenticate(params[:password])
        session[:owner_id] = user.id
        user.update(last_sign_in_at: Time.current, last_sign_in_ip: request.remote_ip)
        redirect_to session.delete(:return_to) || owner_root_path, notice: "Welcome back, #{user.first_name}!"
      else
        flash.now[:alert] = "Invalid email or password."
        render :new, status: :unprocessable_entity
      end
    end

    def destroy
      session.delete(:owner_id)
      redirect_to owner_login_path, notice: "You have been logged out."
    end

    private

    def current_owner
      @current_owner ||= User.find_by(id: session[:owner_id]) if session[:owner_id]
    end
    helper_method :current_owner
  end
end

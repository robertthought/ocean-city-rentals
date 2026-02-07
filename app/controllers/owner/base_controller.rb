module Owner
  class BaseController < ApplicationController
    before_action :require_owner_login

    layout 'owner'

    private

    def require_owner_login
      unless current_owner
        store_location
        redirect_to owner_login_path, alert: "Please log in to continue."
      end
    end

    def current_owner
      @current_owner ||= User.find_by(id: session[:owner_id]) if session[:owner_id]
    end
    helper_method :current_owner

    def store_location
      session[:return_to] = request.fullpath if request.get?
    end

    def redirect_back_or(default)
      redirect_to(session.delete(:return_to) || default)
    end
  end
end

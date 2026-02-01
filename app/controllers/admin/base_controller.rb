module Admin
  class BaseController < ApplicationController
    before_action :authenticate_admin

    layout "admin"

    private

    def authenticate_admin
      authenticate_or_request_with_http_basic("Admin Area") do |username, password|
        username == ENV.fetch("ADMIN_USERNAME", "admin") &&
          password == ENV.fetch("ADMIN_PASSWORD", "changeme")
      end
    end
  end
end

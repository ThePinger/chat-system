class ApplicationController < ActionController::API
    rescue_from ::Exception, :with => :internal_server_error_handler

    def internal_server_error_handler(exception)
        # Log the exception
        print exception
        render json: { error: "internal server error" }, status: :internal_server_error
    end

end

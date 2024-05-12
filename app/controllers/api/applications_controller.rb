class Api::ApplicationsController < ApplicationController

    EXCULDED_FIELDS = ["id", "created_at", "updated_at"]

    # GET /api/applications
    def index
        applications = Application.all
        render json: applications, except: EXCULDED_FIELDS, status: :ok
    end

    # POST /api/applications
    def create
        application = Application.new(name: params[:name])
        if application.save
             render json: application, except: EXCULDED_FIELDS, status: :created
        else
            render json: application.errors, status: :bad_request
        end
    end

    # GET /api/applications/:token
    def show
        application = Application.get_application_by_token(params[:token])
        if application.nil?
            return render json: { error: "application not found" }, status: :not_found
        end
        render json: application, except: EXCULDED_FIELDS, status: :ok
    end

    # PUT /api/applications/:token
    def update
        application = Application.get_application_by_token(params[:token])
        if application.nil?
            return render json: { error: "application not found" }, status: :not_found
        end

        application.name = params[:name]
        if application.save
            render json: application, except: EXCULDED_FIELDS, status: :ok
        else
            render json: application.errors, status: :bad_request
        end
    end

    # DELETE /api/applications/:token
    def destroy
        application = Application.get_application_by_token(params[:token])
        if application.nil?
            return render json: { error: "application not found" }, status: :not_found
        end
        application.destroy
        render json: {}, status: :no_content
    end

end

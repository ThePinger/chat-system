class Api::ChatsController < ApplicationController

    EXCULDED_FIELDS = ["id", "application_id", "created_at", "updated_at"]

    # GET /api/applications/:application_token/chats
    def index
        application = Application.get_application_by_token(params[:application_token])
        if application.nil?
            return render json: { error: "application not found" }, status: :not_found
        end

        chats = application.chats
        render json: { chats: chats }, except: EXCULDED_FIELDS, status: :ok
    end

    # POST /api/applications/:application_token/chats
    def create
        application = Application.get_application_by_token(params[:application_token])
        if application.nil?
            return render json: { error: "application not found" }, status: :not_found
        end

        chat = Chat.new(application_id: application.id)
        if chat.valid?
            # Generate the chat num within the application
            chat.num = Application.increment_chats_count_by_token(params[:application_token])

            if chat.num.nil?
                return render json: { error: "failed to create chat" }, status: :internal_server_error
            end

            # Push the chat to the RabbitMQ
            publisher = Publisher.new("chats")
            publisher.publish(chat)
            publisher.close

            return render json: chat, except: EXCULDED_FIELDS, status: :created
        else
            return render json: chat.errors, status: :bad_request
        end
    end

    # GET /api/applications/:application_token/chats/:num
    def show
        application = Application.get_application_by_token(params[:application_token])
        if application.nil?
            return render json: { error: "application not found" }, status: :not_found
        end

        chat = application.chats.find_by(num: params[:num])
        if chat.nil?
            return render json: { error: "chat not found" }, status: :not_found
        end
        render json: chat, except: EXCULDED_FIELDS, status: :ok
    end

end

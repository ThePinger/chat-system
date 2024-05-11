class Api::MessagesController < ApplicationController

    EXCLUDED_FIELDS = ["id", "chat_id", "created_at", "updated_at"]

    # GET /api/applications/:application_token/chats/:chat_num/messages
    def index
        application = Application.find_by(token: params[:application_token])
        if application.nil?
            return render json: { error: "application not found" }, status: :not_found
        end

        chat = application.chats.find_by(num: params[:chat_num])
        if chat.nil?
            return render json: { error: "chat not found" }, status: :not_found
        end

        messages = chat.messages
        render json: { messages: messages }, except: EXCLUDED_FIELDS, status: :ok
    end

    # POST /api/applications/:application_token/chats/:chat_num/messages
    def create
        application = Application.find_by(token: params[:application_token])
        if application.nil?
            return render json: { error: "application not found" }, status: :not_found
        end

        chat = application.chats.find_by(num: params[:chat_num])
        if chat.nil?
            return render json: { error: "chat not found" }, status: :not_found
        end

        message = Message.new(chat_id: chat.id, content: params[:content])
        if message.save
            render json: message, except: EXCLUDED_FIELDS, status: :created
        else
            render json: message.errors, status: :bad_request
        end
    end

    # GET /api/applications/:application_token/chats/:chat_num/messages/:num
    def show
        application = Application.find_by(token: params[:application_token])
        if application.nil?
            return render json: { error: "application not found" }, status: :not_found
        end

        chat = application.chats.find_by(num: params[:chat_num])
        if chat.nil?
            return render json: { error: "chat not found" }, status: :not_found
        end

        message = chat.messages.find_by(num: params[:num])
        if message.nil?
            return render json: { error: "message not found" }, status: :not_found
        end
        render json: message, except: EXCLUDED_FIELDS, status: :ok
    end
end

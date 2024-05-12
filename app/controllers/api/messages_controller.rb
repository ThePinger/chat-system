class Api::MessagesController < ApplicationController

    EXCLUDED_FIELDS = ["id", "chat_id", "created_at", "updated_at"]

    # GET /api/applications/:application_token/chats/:chat_num/messages
    def index
        chat = Chat.get_chat_by_token_and_num(params[:application_token], params[:chat_num])
        if chat.nil?
            return render json: { error: "chat not found" }, status: :not_found
        end

        if params[:content].present?
            messages = Message.search(params[:content], chat.id)
            messages = messages[2][1].map { |message| message["_source"] }
        else
            messages = chat.messages
        end
        render json: { messages: messages }, except: EXCLUDED_FIELDS, status: :ok
    end

    # POST /api/applications/:application_token/chats/:chat_num/messages
    def create
        chat = Chat.get_chat_by_token_and_num(params[:application_token], params[:chat_num])
        if chat.nil?
            return render json: { error: "chat not found" }, status: :not_found
        end

        message = Message.new(chat_id: chat.id, content: params[:content])
        if message.valid?
            # Generate the message num within the chat
            message.num = Chat.increment_messages_count_by_token_and_num(params[:application_token], params[:chat_num])
            if message.num.nil?
                return render json: { error: "failed to create message" }, status: :internal_server_error
            end

            # Push the chat to the RabbitMQ
            publisher = Publisher.new("messages")
            publisher.publish(message)
            publisher.close

            return render json: message, except: EXCLUDED_FIELDS, status: :created
        else
            return render json: message.errors, status: :bad_request
        end
    end

    # GET /api/applications/:application_token/chats/:chat_num/messages/:num
    def show
        chat = Chat.get_chat_by_token_and_num(params[:application_token], params[:chat_num])
        if chat.nil?
            return render json: { error: "chat not found" }, status: :not_found
        end

        message = chat.messages.find_by(num: params[:num])
        if message.nil?
            return render json: { error: "message not found" }, status: :not_found
        end
        render json: message, except: EXCLUDED_FIELDS, status: :ok
    end

    # PUT /api/applications/:application_token/chats/:chat_num/messages/:num
    def update
        chat = Chat.get_chat_by_token_and_num(params[:application_token], params[:chat_num])
        if chat.nil?
            return render json: { error: "chat not found" }, status: :not_found
        end

        message = chat.messages.find_by(num: params[:num])
        if message.nil?
            return render json: { error: "message not found" }, status: :not_found
        end

        message.content = params[:content]
        if message.save
            return render json: message, except: EXCLUDED_FIELDS, status: :ok
        else
            return render json: message.errors, status: :bad_request
        end
    end
end

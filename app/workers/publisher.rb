class Publisher
    def initialize (type)
        if type != "chats" && type != "messages"
            raise "Invalid exchange type"
        end
        @type = type
        @connection = Bunny.new(hostname: ENV['RABBITMQ_HOST'] || 'rabbitmq')
        @connection.start
        @channel = @connection.create_channel
        @exchange = @channel.direct(@type, durable: true)
    end

    def publish(obj)
        if @type == "chats"
            chat = obj
            @exchange.publish(chat.to_json, routing_key: @type, persistent: true)
            print "Chat published: " + chat.to_json + "\n"
        else
            message = obj
            @exchange.publish(message.to_json, routing_key: @type, persistent: true)
            print "Message published: " + message.to_json + "\n"
        end
    end

    def close
        @connection.close
    end
end

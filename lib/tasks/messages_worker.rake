
task :messages_worker => :environment do
    connection = Bunny.new
    connection.start
    channel = connection.create_channel
    messages_exchange = channel.direct('messages', durable: true)
    messages_queue = channel.queue('messages_queue', durable: true)
    messages_queue.bind(messages_exchange, routing_key: 'messages')

    puts ' [*] Waiting for chats. To exit press CTRL+C'

    begin
        messages_queue.subscribe(manual_ack: true, block: true) do |delivery_info, _properties, body|
        puts " [x] Received '#{body}'"
        message = JSON.parse(body, object_class: Message)
        message.save
        puts ' [x] Done'
        channel.ack(delivery_info.delivery_tag)
        end
    rescue Interrupt => _
        connection.close
    end
end

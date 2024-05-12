
task :chats_worker => :environment do
    connection = Bunny.new
    connection.start
    channel = connection.create_channel
    chats_exchange = channel.direct('chats', durable: true)
    chats_queue = channel.queue('chats_queue', durable: true)
    chats_queue.bind(chats_exchange, routing_key: 'chats')

    puts ' [*] Waiting for chats. To exit press CTRL+C'

    begin
        chats_queue.subscribe(manual_ack: true, block: true) do |delivery_info, _properties, body|
        puts " [x] Received '#{body}'"
        chat = JSON.parse(body, object_class: Chat)
        chat.save
        puts ' [x] Done'
        channel.ack(delivery_info.delivery_tag)
        end
    rescue Interrupt => _
        connection.close
    end
end

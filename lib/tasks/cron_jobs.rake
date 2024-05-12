namespace :cron_jobs do
  desc "Update counts of chats and messages for all applications"
  task update_counts: :environment do
        puts "Updating counts of chats and messages for all applications\n"

        puts "Updating counts of chats for all applications\n"
        applications = Application.all
        applications.each do |application|
            count = Rails.cache.read("application_#{application.token}_count_chats")
            if count.nil?
                application.chats_count = application.chats.count
            else
                application.chats_count = count
            end
            application.save
        end

        puts "Updating counts of messages for all chats\n"
        chats = Chat.all
        chats.each do |chat|
            count = Rails.cache.read("chat_#{chat.application.token}_#{chat.num}_count_messages")
            if count.nil?
                chat.messages_count = chat.messages.count
            else
                chat.messages_count = count
            end
            chat.save
        end
  end

end

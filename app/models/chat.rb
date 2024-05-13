class Chat < ApplicationRecord
    belongs_to :application
    has_many :messages, dependent: :destroy

    after_create do
        Rails.cache.write("chat_#{self.application.token}_#{self.num}", self.to_json)
        Rails.cache.write("chat_#{self.application.token}_#{self.num}_messages_count", 0)
    end

    after_update do
        Rails.cache.write("chat_#{self.application.token}_#{self.num}", self.to_json)
    end

    after_destroy do
        Rails.cache.write("chat_#{self.application.token}_#{self.num}", self.to_json)
    end

    def self.get_chat_by_token_and_num(application_token, num)
        key = "chat_#{application_token}_#{num}"
        if Rails.cache.exist?(key)
            chat = Rails.cache.read(key)
            chat = JSON.parse(chat, object_class: Chat) if chat.present?
        else
            application = Application.get_application_by_token(application_token)
            chat = Chat.find_by(application_id: application.id, num: num) if application.present?
            Rails.cache.write(key, chat.to_json) if chat.present?
        end
        return chat
    end

    def self.increment_messages_count_by_token_and_num(application_token, num)
        key = "chat_#{application_token}_#{num}_messages_count"

        # Lock the cache key using redlock
        lock_manager = Redlock::Client.new([ENV["REDIS_URL"] || 'redis://redis:6379'], {
            retry_count: 3,
            retry_delay: 200
        })

        begin
            messages_count = lock_manager.lock!("#{key}_lock", 5000) do
                if Rails.cache.exist?(key)
                    count = Rails.cache.read(key)
                    count = count.to_i + 1
                    Rails.cache.write(key, count)
                else
                    application = Application.get_application_by_token(application_token)
                    chat = Chat.find_by(application_id: application.id, num: num)
                    count = chat.messages.count + 1
                    Rails.cache.write(key, count)
                end
                count
            end
            return messages_count
        rescue Redlock::LockError
            # error handling
            print "Error: LockError"
            return nil
        end
    end
end

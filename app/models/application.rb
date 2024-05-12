class Application < ApplicationRecord
    has_many :chats

    validates :name, presence: true, length: { maximum: 255 }

    before_create do
        # Generate a unique cuid token for the application
        self.token = Cuid.generate
    end

    after_create do
        Rails.cache.write("application_#{self.token}", self.to_json)
        Rails.cache.write("application_#{self.token}_chats_count", 0)
    end

    after_update do
        Rails.cache.write("application_#{self.token}", self.to_json)
    end

    after_destroy do
        Rails.cache.delete("application_#{self.token}")
    end

    def self.get_application_by_token(token)
        key = "application_#{token}"
        if Rails.cache.exist?(key)
            application = Rails.cache.read(key)
            application = JSON.parse(application, object_class: Application) if application.present?
        else
            application = Application.find_by(token: token)
            Rails.cache.write(key, application.to_json) if application.present?
        end
        return application
    end

    def self.increment_chats_count_by_token(token)
        key = "application_#{token}_chats_count"
        # Lock the cache key using redlock
        lock_manager = Redlock::Client.new(["redis://127.0.0.1:6379"], {
            retry_count: 3,
            retry_delay: 200
        })

        begin
            chats_count = lock_manager.lock!("#{key}_lock", 2000) do
                if Rails.cache.exist?(key)
                    count = Rails.cache.read(key)
                    count = count.to_i + 1
                    Rails.cache.write(key, count)
                else
                    application = Application.find_by(token: token)
                    count = application.chats.count + 1
                    Rails.cache.write(key, count)
                end
                count
            end
            return chats_count
        rescue Redlock::LockError
            # error handling
            print "Error: LockError"
            return nil
        end
    end
end

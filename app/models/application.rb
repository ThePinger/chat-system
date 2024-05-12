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
        if Rails.cache.exist?("application_#{token}")
            application = Rails.cache.read("application_#{token}")
            application = JSON.parse(application, object_class: Application) if application.present?
        else
            application = Application.find_by(token: token)
            Rails.cache.write("application_#{token}", application.to_json) if application.present?
        end
        return application
    end

    def self.increment_chats_count_by_token(token)
        # Lock the cache key using redlock
        lock_manager = Redlock::Client.new(["redis://127.0.0.1:6379"], {
            retry_count: 3,
            retry_delay: 200
        })

        begin
            chats_count = lock_manager.lock!("application_#{token}_chats_count_lock", 2000) do
                if Rails.cache.exist?("application_#{token}_chats_count")
                    count = Rails.cache.read("application_#{token}_chats_count")
                    count = count.to_i + 1
                    Rails.cache.write("application_#{token}_chats_count", count)
                else
                    application = Application.find_by(token: token)
                    count = application.chats.count + 1
                    Rails.cache.write("application_#{token}_chats_count", count)
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

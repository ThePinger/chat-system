class Chat < ApplicationRecord
    belongs_to :application
    has_many :messages, dependent: :destroy

    before_create do
        # Generate the chat num within the application
        self.num = self.application.chats.count + 1
    end
end

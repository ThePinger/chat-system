class Message < ApplicationRecord
    belongs_to :chat

    validates :content, presence: true

    before_create do
        # Generate the message num within the chat
        self.num = self.chat.messages.count + 1
    end
end

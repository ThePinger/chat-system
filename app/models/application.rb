class Application < ApplicationRecord
    has_many :chats

    validates :name, presence: true, length: { maximum: 255 }

    before_create do
        # Generate a unique cuid token for the application
        self.token = Cuid.generate
    end
end

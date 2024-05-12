class Message < ApplicationRecord
    include Searchable

    belongs_to :chat

    validates :content, presence: true
end

class CreateMessages < ActiveRecord::Migration[7.1]
  def change
    create_table :messages do |t|
        t.integer :num, null: false
        t.text :content, null: false
        t.references :chat, null: false, foreign_key: { on_delete: :cascade }
        t.timestamps
        # A composite index to ensure that the message number is unique within a chat
        t.index [:chat_id, :num], unique: true
    end
  end
end

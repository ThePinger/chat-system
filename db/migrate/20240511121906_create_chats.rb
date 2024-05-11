class CreateChats < ActiveRecord::Migration[7.1]
  def change
    create_table :chats do |t|
        t.integer :num, null: false
        t.integer :messages_count, null: false, default: 0
        t.references :application, null: false, foreign_key: { on_delete: :cascade }
        t.timestamps
        # A composite index to ensure that the chat number is unique within an application
        t.index [:application_id, :num], unique: true
    end
  end
end

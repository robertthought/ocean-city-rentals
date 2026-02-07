class CreatePropertyEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :property_events do |t|
      t.references :property, null: false, foreign_key: true
      t.string :event_type, null: false
      t.string :session_id
      t.string :ip_address
      t.string :user_agent
      t.string :referrer
      t.jsonb :metadata, default: {}
      t.datetime :created_at, null: false
    end
    add_index :property_events, [:property_id, :event_type, :created_at]
    add_index :property_events, :created_at
  end
end

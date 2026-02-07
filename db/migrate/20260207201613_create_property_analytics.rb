class CreatePropertyAnalytics < ActiveRecord::Migration[8.1]
  def change
    create_table :property_analytics do |t|
      t.references :property, null: false, foreign_key: true
      t.date :date, null: false
      t.integer :page_views, default: 0
      t.integer :search_impressions, default: 0
      t.integer :unique_visitors, default: 0

      t.timestamps
    end
    add_index :property_analytics, [:property_id, :date], unique: true
    add_index :property_analytics, :date
  end
end

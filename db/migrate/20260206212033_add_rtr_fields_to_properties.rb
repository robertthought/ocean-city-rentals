class AddRtrFieldsToProperties < ActiveRecord::Migration[8.1]
  def change
    add_column :properties, :rtr_reference_id, :integer
    add_column :properties, :rtr_property_id, :integer
    add_column :properties, :description, :text
    add_column :properties, :photos, :jsonb, default: []
    add_column :properties, :amenities, :jsonb, default: []
    add_column :properties, :property_name, :string
    add_column :properties, :occupancy_limit, :integer
    add_column :properties, :total_sleeps, :integer
    add_column :properties, :smoking, :boolean
    add_column :properties, :fee_descriptions, :text
    add_column :properties, :rate_description, :text
    add_column :properties, :broker_name, :string
    add_column :properties, :broker_phone, :string
    add_column :properties, :broker_email, :string
    add_column :properties, :broker_website, :string
    add_column :properties, :virtual_tour_url, :string
    add_column :properties, :rtr_synced_at, :datetime

    add_index :properties, :rtr_reference_id, unique: true, where: "rtr_reference_id IS NOT NULL"
  end
end

class AddOwnerFieldsToProperties < ActiveRecord::Migration[8.1]
  def change
    add_column :properties, :owner_customized, :boolean, default: false
    add_column :properties, :owner_description, :text
    add_column :properties, :owner_amenities, :jsonb, default: []
    add_column :properties, :photo_order, :jsonb, default: []
  end
end

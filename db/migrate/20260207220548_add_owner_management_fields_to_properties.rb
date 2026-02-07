class AddOwnerManagementFieldsToProperties < ActiveRecord::Migration[8.1]
  def change
    # owner_amenities already exists from previous migration
    add_column :properties, :owner_pet_friendly, :boolean, default: nil unless column_exists?(:properties, :owner_pet_friendly)
    add_column :properties, :owner_special_notes, :text unless column_exists?(:properties, :owner_special_notes)
    add_column :properties, :owner_rental_type, :string, default: 'weekly' unless column_exists?(:properties, :owner_rental_type)
    add_column :properties, :owner_weekly_rate, :decimal, precision: 10, scale: 2 unless column_exists?(:properties, :owner_weekly_rate)
    add_column :properties, :owner_nightly_rate, :decimal, precision: 10, scale: 2 unless column_exists?(:properties, :owner_nightly_rate)
    add_column :properties, :owner_minimum_nights, :integer, default: 7 unless column_exists?(:properties, :owner_minimum_nights)
  end
end

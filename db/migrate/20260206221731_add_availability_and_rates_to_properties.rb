class AddAvailabilityAndRatesToProperties < ActiveRecord::Migration[8.1]
  def change
    add_column :properties, :availability, :jsonb, default: []
    add_column :properties, :rates, :jsonb, default: []
  end
end

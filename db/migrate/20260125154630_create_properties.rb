class CreateProperties < ActiveRecord::Migration[8.1]
  def change
    create_table :properties do |t|
      t.string :property_id # From CSV
      t.string :address, null: false
      t.string :city, null: false
      t.string :state, null: false, default: 'NJ'
      t.string :zip, null: false

      # Owner info
      t.string :person_type
      t.boolean :is_verified
      t.boolean :auto_verified
      t.string :first_name
      t.string :last_name
      t.string :email_1
      t.string :email_2
      t.string :email_3
      t.string :email_4
      t.string :phone_1
      t.string :phone_2
      t.string :phone_3
      t.string :phone_4

      # Mailing address
      t.string :mailing_address
      t.string :mailing_city
      t.string :mailing_state
      t.string :mailing_zip
      t.string :data_source

      # SEO
      t.string :slug, null: false
      t.text :meta_description
      t.text :meta_keywords

      # Future fields (nullable for now)
      t.decimal :latitude, precision: 10, scale: 6
      t.decimal :longitude, precision: 10, scale: 6
      t.integer :bedrooms
      t.integer :bathrooms
      t.integer :year_built
      t.string :property_type

      t.timestamps
    end

    add_index :properties, :slug, unique: true
    add_index :properties, :zip
    add_index :properties, :city
    add_index :properties, [:city, :zip]
    add_index :properties, :property_id
  end
end

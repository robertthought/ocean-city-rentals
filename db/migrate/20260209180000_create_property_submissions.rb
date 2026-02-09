class CreatePropertySubmissions < ActiveRecord::Migration[8.1]
  def change
    create_table :property_submissions do |t|
      t.string :owner_name, null: false
      t.string :email, null: false
      t.string :phone
      t.string :property_address, null: false
      t.string :city
      t.string :state
      t.string :zip
      t.integer :bedrooms
      t.integer :bathrooms
      t.text :message
      t.boolean :reviewed, default: false
      t.datetime :reviewed_at
      t.float :recaptcha_score

      t.timestamps
    end

    add_index :property_submissions, :reviewed
    add_index :property_submissions, :created_at
    add_index :property_submissions, :email
  end
end

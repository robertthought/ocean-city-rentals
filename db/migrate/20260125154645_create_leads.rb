class CreateLeads < ActiveRecord::Migration[8.1]
  def change
    create_table :leads do |t|
      t.references :property, null: false, foreign_key: true

      # Lead info
      t.string :name, null: false
      t.string :email, null: false
      t.string :phone
      t.text :message
      t.string :lead_type, default: 'rental_inquiry' # rental_inquiry, property_info, etc

      # Metadata
      t.string :source # direct, google, referral
      t.string :ip_address
      t.string :user_agent
      t.boolean :contacted, default: false
      t.datetime :contacted_at

      t.timestamps
    end

    add_index :leads, :email
    add_index :leads, :created_at
    add_index :leads, :contacted
  end
end

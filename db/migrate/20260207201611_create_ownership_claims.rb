class CreateOwnershipClaims < ActiveRecord::Migration[8.1]
  def change
    create_table :ownership_claims do |t|
      t.references :user, null: false, foreign_key: true
      t.references :property, null: false, foreign_key: true
      t.string :status, null: false, default: 'pending'
      t.text :verification_notes, null: false
      t.text :admin_notes
      t.datetime :reviewed_at
      t.string :reviewed_by

      t.timestamps
    end
    add_index :ownership_claims, [:user_id, :property_id], unique: true
    add_index :ownership_claims, :status
  end
end

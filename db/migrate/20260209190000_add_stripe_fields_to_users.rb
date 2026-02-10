class AddStripeFieldsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :stripe_customer_id, :string
    add_column :users, :subscription_plan, :string, default: 'free'
    add_column :users, :subscription_status, :string, default: 'active'
    add_column :users, :subscription_expires_at, :datetime
    add_column :users, :stripe_subscription_id, :string

    add_index :users, :stripe_customer_id, unique: true
    add_index :users, :subscription_plan
  end
end

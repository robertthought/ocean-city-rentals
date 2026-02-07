class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :email, null: false
      t.string :password_digest, null: false
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :phone
      t.string :reset_password_token
      t.datetime :reset_password_sent_at
      t.datetime :last_sign_in_at
      t.string :last_sign_in_ip
      t.boolean :email_verified, default: false
      t.string :email_verification_token

      t.timestamps
    end
    add_index :users, :email, unique: true
    add_index :users, :reset_password_token, unique: true
  end
end

class CreateContactSubmissions < ActiveRecord::Migration[8.1]
  def change
    create_table :contact_submissions do |t|
      t.string :name
      t.string :email
      t.string :phone
      t.string :inquiry_type
      t.text :message
      t.boolean :responded, default: false
      t.datetime :responded_at

      t.timestamps
    end

    add_index :contact_submissions, :responded
    add_index :contact_submissions, :created_at
  end
end

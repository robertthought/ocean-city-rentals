class AddSpamFieldsToContactSubmissions < ActiveRecord::Migration[8.1]
  def change
    add_column :contact_submissions, :spam, :boolean, default: false, null: false
    add_column :contact_submissions, :spam_reason, :string
    add_index :contact_submissions, :spam
  end
end

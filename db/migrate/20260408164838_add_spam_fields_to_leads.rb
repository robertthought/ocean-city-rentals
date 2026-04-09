class AddSpamFieldsToLeads < ActiveRecord::Migration[8.1]
  def change
    add_column :leads, :spam, :boolean, default: false, null: false
    add_column :leads, :spam_reason, :string
    add_index :leads, :spam
  end
end

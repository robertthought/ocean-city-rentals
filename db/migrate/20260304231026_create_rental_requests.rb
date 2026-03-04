class CreateRentalRequests < ActiveRecord::Migration[8.1]
  def change
    create_table :rental_requests do |t|
      t.string :name
      t.string :email
      t.string :phone
      t.integer :bedrooms
      t.integer :bathrooms
      t.integer :sleeps
      t.date :check_in_date
      t.date :check_out_date
      t.boolean :flexible_dates
      t.text :location_preferences
      t.text :amenities
      t.integer :budget_min
      t.integer :budget_max
      t.text :additional_comments
      t.decimal :recaptcha_score
      t.boolean :contacted
      t.datetime :contacted_at

      t.timestamps
    end
  end
end

class AddOwnerWeeklyCalendarToProperties < ActiveRecord::Migration[8.1]
  def change
    add_column :properties, :owner_weekly_calendar, :jsonb, default: {}
  end
end

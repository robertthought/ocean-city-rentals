class AddRecaptchaScoreToLeads < ActiveRecord::Migration[8.1]
  def change
    add_column :leads, :recaptcha_score, :decimal
    add_column :contact_submissions, :recaptcha_score, :decimal
  end
end

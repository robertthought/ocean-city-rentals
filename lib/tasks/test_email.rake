namespace :email do
  desc "Test email delivery to bob@bobidell.com"
  task test: :environment do
    puts "Testing email delivery..."
    puts "RESEND_API_KEY present: #{ENV['RESEND_API_KEY'].present?}"

    # Create a test mailer
    class TestMailer < ApplicationMailer
      def test_email
        mail(
          to: "bob@bobidell.com",
          subject: "Test Email from OCNJ Rentals - #{Time.current}",
          body: "This is a test email to verify email delivery is working.\n\nSent at: #{Time.current}"
        )
      end
    end

    begin
      TestMailer.test_email.deliver_now
      puts "Email sent successfully! Check bob@bobidell.com"
    rescue => e
      puts "Email failed: #{e.class} - #{e.message}"
      puts e.backtrace.first(5).join("\n")
    end
  end
end
